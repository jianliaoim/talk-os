Promise = require 'bluebird'
Err = require 'err1st'
_ = require 'lodash'
serviceLoader = require 'talk-services'
limbo = require 'limbo'
logger = require 'graceful-logger'

app = require '../server'

$service = serviceLoader.load 'outgoing'

{
  IntegrationModel
  MessageModel
} = limbo.use 'talk'

_postMessage = ({message, integration}) ->
  {url, token} = integration
  msg = _.clone message
  msg.token = token if token?.length
  msg.event = 'message.create'

  $body = @httpPost url, msg, retryTimes: 5

  Promise.all [$body, $service]

  .spread (body = {}, service) ->
    return unless body.text or body.content
    replyMessage = new MessageModel
      body: body.content
      authorName: body.authorName
      creator: service.robot._id
      displayType: body.displayType
    if body.text
      attachment =
        category: 'quote'
        color: body.color
        data: body
      attachment.data.category = 'outgoing'
      replyMessage.attachments = [attachment]
    replyMessage.room = integration._roomId
    replyMessage.team = integration._teamId
    replyMessage.$save()

  .then (message) ->
    # Reset errorTimes
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

$service.then (service) ->

  service.registerEvent 'message.create', _postMessage

# Register hook after create message
app.controller 'message', ->

  @after 'sendMsgToOutgoing', only: 'create', parallel: true

  @action 'sendMsgToOutgoing', (req, res, message) ->
    return unless message._roomId

    $integrations = IntegrationModel.findAsync
      room: message._roomId
      category: 'outgoing'
      errorInfo: null

    $replyMessages = $integrations.map (integration) ->

      $service.then (service) ->
        req.integration = integration
        req.message = message
        service.receiveEvent 'message.create', req

    .catch (err) -> logger.warn err.stack
