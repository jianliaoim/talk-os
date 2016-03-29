async = require 'async'
_ = require 'lodash'
Err = require 'err1st'
path = require 'path'
Promise = require 'bluebird'
request = require 'request'
he = require 'he'
serviceLoader = require 'talk-services'
uuid = require 'uuid'
config = require 'config'
limbo = require 'limbo'

{mailgun, logger, redis} = require '../components'
util = require '../util'
app = require '../server'

{
  IntegrationModel
  MessageModel
  UserModel
  RoomModel
  FileModel
} = limbo.use 'talk'

_parseMailgunSender = (sender, from) ->
  if from and matchFrom = from.match /^(.*)\<(.*)\>/i
    [all, sender] = matchFrom
  else if from
    sender = from
  else if matches = sender?.match /(.*?)\+auto_/
    emailName = matches[1]
    sender = emailName + '@' + sender.split('@')[1]
  sender = sender?.trim()
  # Remove quotes when sender name is wrapped by quotes
  sender = sender[1...sender.length - 1] if sender?.charAt(0) is '"'
  sender

module.exports = serviceController = app.controller 'service', ->

  @mixin require './mixins/permission'

  @ratelimit '60', only: 'webhook'

  @ensure 'hashId', only: 'webhook'
  @ensure '_teamId url', only: 'toApp'
  @ensure 'msgToken', only: 'createMessage'

  @before 'parseMsgToken', only: 'createMessage'
  @before 'accessibleMessage', only: 'toApp'
  @after 'clearMsgToken', only: 'createMessage', parallel: true

  @action 'webhook', (req, res, callback) ->
    {hashId} = req.get()

    $integration = IntegrationModel.findOneAsync hashId: hashId
    .then (integration) ->
      throw new Err('OBJECT_MISSING', 'integration') unless integration
      throw new Err('INTEGRATION_ERROR_DISABLED', integration.errorInfo) if integration.errorInfo
      integration

    $service = $integration.then (integration) ->
      serviceLoader.load integration.category

    # Waiting for message object
    $message = Promise.all [$service, $integration]

    .spread (service, integration) ->

      req.integration = integration

      service.receiveEvent 'service.webhook', req, res

      .then (message) ->
        return message unless integration.errorTimes > 0
        integration.errorTimes = 0
        integration.lastErrorInfo = undefined
        integration.errorInfo = undefined
        integration.$save().then -> message

      .catch (err) ->
        integration.errorTimes += 1
        integration.lastErrorInfo = err.message
        integration.errorInfo = err.message if integration.errorTimes > 5
        integration.$save()
        throw err

    # Create real message
    $message = Promise.all [$message, $service, $integration]

    .spread (message, service, integration) ->
      return message unless toString.call(message) is '[object Object]' and not _.isEmpty(message)
      message = new MessageModel message
      message.room or= integration._roomId if integration._roomId
      message.team or= integration._teamId if integration._teamId
      message.creator or= service.robot._id
      message.integration = integration
      message.$save()

    $message.then (message) -> callback null, message

    .catch (err) ->
      if err?.code is 401 and err?.params?[0] is 'integration'
        # Response 200 when integation is not existing
        # Some service will check for this api before creating integration
        return callback null, ok: 1
      unless err instanceof Err
        err = new Err 'INTEGRATION_ERROR', err?.message
      callback err

  @action 'api', (req, res, callback) ->
    {apiName, category} = req.get()

    $service = serviceLoader.load category

    $service.then (service) -> service.receiveApi apiName, req, res

    .nodeify callback

  @action 'settings', (req, res, callback) -> serviceLoader.settings().nodeify callback

  @action 'toApp', (req, res, callback) ->
    {_roomId, _toId, _teamId, _sessionUserId, url} = req.get()
    data =
      _creatorId: _sessionUserId
      _teamId: _teamId
    if _roomId then data._roomId = _roomId else data._toId = _toId
    $user = UserModel.findOneAsync _id: _sessionUserId
    $msgToken = MessageModel.setMsgTokenAsync data

    Promise.all [$user, $msgToken]

    .then ([user, msgToken]) ->
      params =
        msgToken: msgToken
        userName: user.name
      res.redirect 302, util.buildAppMsgUrl url, params

    .catch callback

  ###*
   * Set _teamId, _roomId, _sessionUserId from msgToken
   * @param  {Request}   req
   * @param  {Response}   res
   * @param  {Function} callback [description]
  ###
  @action 'parseMsgToken', (req, res, callback) ->
    {msgToken, attachments} = req.get()
    return callback() unless msgToken
    MessageModel.getMsgToken msgToken, (err, data) ->
      return callback(new Err 'INVALID_MSG_TOKEN') unless data
      {_creatorId, _roomId, _teamId, _toId} = data
      req.set '_sessionUserId', _creatorId
      req.set '_roomId', _roomId, true if _roomId
      req.set '_teamId', _teamId, true if _teamId
      req.set '_toId', _toId, true if _toId
      attachments = attachments?.map (attachment) ->
        return unless attachment?.category and attachment?.data
        attachment.data.category = 'thirdapp'
        attachment
      .filter (attachment) -> attachment
      req.set 'attachments', attachments if attachments
      callback()

  @action 'clearMsgToken', (req, res, message) ->
    {msgToken} = req.get()
    return unless msgToken
    MessageModel.clearMsgToken msgToken

  @action 'createMessage', (req, res, callback) ->
    app.controller('message').call 'create', req, res, callback

  # Messages from mailgun
  @action 'mailgun', (req, res, callback = ->) ->
    # @osv
    return callback(null, ok: 1)
    body = req.body

    unless _.isEmpty(req.files)  # Save attachment to file server and create file model
      _parseToFileArray = ->
        files = []
        for key, val of req.files
          if toString.call(val) is '[object Array]'
            files = files.concat val
          else
            files.push val
        files
      $file = Promise.promisify(util.saveToFileServer) _parseToFileArray()

    $robot = serviceLoader.getRobotOf 'email'

    # Find room
    $room = Promise.resolve().then ->

      {timestamp, token, signature} = body
      unless config.debug or mailgun.validateWebhook(timestamp, token, signature)
        logger.warn "invalid mailgun webhook: ", timestamp, token, signature
        throw new Err('SIGNATURE_FAILED')

      if body['body-html']
        body.bodyHtml = util.extractBodyContent body['body-html']
      else if body['body-plain']
        body.bodyHtml = body['body-plain']

      throw new Err('PARAMS_MISSING', 'body') unless body.bodyHtml

      {recipient, sender, from} = body

      throw new Err('PARAMS_MISSING', 'recipient, sender') unless recipient

      body.sender = _parseMailgunSender sender, from

      RoomModel.findOneAsync email: body.recipient

    # Create message
    Promise.all [$room, $robot]

    .spread (room, robot) ->

      throw new Err('OBJECT_MISSING', 'room') unless room

      body.room = room

      body.user = robot

      authorName = he.decode(body.sender or '')
      authorName = undefined unless authorName?.length

      message = new MessageModel
        creator: body.user._id
        team: body.room._teamId
        room: body.room._id
        authorName: authorName

      quote =
        category: 'quote'
        data:
          category: 'mailgun'
          title: he.decode(body.subject or '')
          text: he.decode(body.bodyHtml or '')

      attachments = [quote]

      if $file?

        $file = $file.then (fileDatas) ->
          fileDatas = [fileDatas] unless toString.call(fileDatas) is '[object Array]'
          fileDatas

        $thumbnailMap = $file.then (fileDatas = []) ->
          thumbnailMap = {}  # Map filename to thumbnail url
          fileDatas.forEach (fileData) ->
            file = new FileModel fileData

            fileName = fileData.fileName
            fileNameParts = fileName.split('.')
            fileNameParts = fileNameParts[0...-1] if fileNameParts.length > 1
            # Save thumbnail url of file without extname
            baseFileName = fileNameParts.join('.')
            data = thumbnailUrl: file.thumbnailUrl, fileName: fileName
            thumbnailMap[fileName] = data
            thumbnailMap[baseFileName] = data
          thumbnailMap

        $message = Promise.all [$file, $thumbnailMap]

        .spread (fileDatas, thumbnailMap) ->

          matchedFileNames = {}

          quote.data.text = body.bodyHtml.replace /"cid:(.*?)"/ig, (match, submatch) ->
            submatch = submatch?.trim()
            return match unless thumbnailMap[submatch]?.thumbnailUrl
            matchedFileNames[thumbnailMap[submatch].fileName] = 1
            return "\"#{thumbnailMap[submatch].thumbnailUrl}\""

          fileModels = fileDatas?.filter (fileData) ->
            (not matchedFileNames[fileData.fileName]) or fileData.imageWidth > 500 or fileData.imageHeight > 500
          .map (fileData) ->
            category: 'file'
            data: fileData

          attachments = attachments.concat fileModels if fileModels?.length

          message

      else $message = Promise.resolve(message)

      $message.then (message) ->
        message.attachments = attachments
        message.$save()

    .then -> ok: 1

    .nodeify callback
