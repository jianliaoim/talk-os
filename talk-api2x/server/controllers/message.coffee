async = require 'async'
_ = require 'lodash'
Promise = require 'bluebird'
Err = require 'err1st'
limbo = require 'limbo'
logger = require 'graceful-logger'

util = require '../util'
{rmMailer, dmMailer, smMailer} = require '../mailers'
messageSearcher = require '../searchers/message'
app = require '../server'
{redis, schedule} = require '../components'

{
  MessageModel
  UserModel
  RoomModel
  TagModel
  NotificationModel
  MarkModel
} = limbo.use 'talk'

module.exports = messageController = app.controller 'message', ->

  @mixin require './mixins/permission'

  @ratelimit '60 300', only: 'search'

  @ensure '_teamId', only: 'search'
  @ensure '_messageIds', only: 'reposts'

  @before 'ensureTeamId', only: 'create read clear search mentions tags'
  @before 'readableMessage', only: 'repost receipt'
  @before 'accessibleMessage', only: 'create repost'
  @before 'readableMessages', only: 'read clear'
  @before 'editableMessage', only: 'update'
  @before 'checkTags', only: 'update'
  @before 'deletableMessage', only: 'remove'
  @before 'isTeamMember', only: 'search mentions tags'

  @after 'populateMessage', only: 'create update remove repost receipt'

  @after 'afterUpdate', only: 'update', parallel: true
  @after 'afterRemove', only: 'remove', parallel: true
  @after 'afterClear', only: 'clear', parallel: true
  @after 'getUrlContent', only: 'create update', parallel: true
  @after 'addSchedule', only: 'create update', parallel: true
  @after 'removeSchedule', only: 'remove', parallel: true

  editableFields = [
    'body'
    'attachments'
    '_tagIds'
  ]

  @action 'create', (req, res, callback) ->
    {_sessionUserId, _toId, _roomId, _teamId, mark, attachments} = req.get()

    message = _.assign req.get(), _creatorId: _sessionUserId
    message = new MessageModel message
    message.socketId = req.get 'socketId'

    $message = Promise.resolve().then ->
      # Check attachments
      if attachments?.length
        attachments.forEach (attachment) ->
          switch attachment.category
            when 'calendar'
              unless new Date(attachment.data?.remindAt) > Date.now()
                throw new Err('PARAMS_INVALID', 'remindAt')
      message

    # Add message.mark
    if mark?.x and mark?.y
      markOptions = _.assign {}, mark,
        target: message._targetId
        type: message.type
        team: message._teamId
        creator: message._creatorId
        text: message.body
      $mark = MarkModel.createByOptionsAsync markOptions

      $message = Promise.all [$message, $mark]
      .spread (message, mark) ->
        message.mark = mark._id
        return message

    $message = $message.then (message) -> message.$save()
    $message.nodeify callback

  @action 'read', (req, res, callback) ->
    MessageModel.findByOptions req.get(), callback

  @action 'receipt', (req, res, callback) ->
    {_sessionUserId} = req.get()
    MessageModel.findOneAndUpdate
      _id: req.get('_id')
    ,
      $addToSet: receiptors: [_sessionUserId]
    ,
      new: true
    , (err, message) ->
      return callback(err) unless message
      message.socketId = req.get 'socketId'
      message.needSearch = false
      message.emit 'updated', message
      callback err, message

  @action 'mentions', (req, res, callback) ->
    {_sessionUserId, _teamId} = req.get()
    hasIndexKey = ['_toId', '_roomId', '_storyId'].some (key) -> req.get(key)
    if hasIndexKey
      $readable = @readableMessagesAsync req, res
      $messages = $readable.then ->
        req.set '_mentionId', _sessionUserId
        MessageModel.findByOptionsAsync req.get()
    else
      $messages = MessageModel.findAllMentionsAsync _sessionUserId, _teamId, req.get()

    $messages.nodeify callback

  @action 'tags', (req, res, callback) ->
    {_sessionUserId, _teamId} = req.get()

    hasIndexKey = ['_toId', '_roomId', '_storyId'].some (key) -> req.get(key)

    if hasIndexKey
      $readable = @readableMessagesAsync req, res
      $messages = $readable.then ->
        req.set 'hasTag', true
        MessageModel.findByOptionsAsync req.get()
    else
      $messages = MessageModel.findAllTagsAsync _sessionUserId, _teamId, req.get()

    $messages.nodeify callback

  @action 'checkTags', (req, res, callback) ->
    {_tagIds, message} = req.get()
    return callback() unless _tagIds?.length
    {_teamId} = message
    TagModel.find
      _id: $in: _tagIds
      team: message._teamId
    , (err, tags) ->
      _foundTagIds = tags.map (tag) -> "#{tag._id}"
      validTags = _tagIds.every (_tagId) -> _tagId in _foundTagIds
      unless validTags
        return callback(new Err('PARAMS_INVALID', "_tagIds"))
      callback()

  @action 'update', (req, res, callback) ->
    {message, _tagIds, socketId} = req.get()
    update = _.pick req.get(), editableFields
    return callback(new Err 'PARAMS_MISSING', editableFields.join(', ')) if _.isEmpty(update)

    $message = Promise.resolve(message).then (message) ->
      if update.attachments?.length
        update.attachments.forEach (attachment) ->
          switch attachment.category
            when 'calendar'
              unless new Date(attachment.data?.remindAt) > Date.now()
                throw new Err('PARAMS_INVALID', 'remindAt')

      for key, val of update
        message[key] = val
      message.tags = _tagIds if _tagIds
      # Do not update message date when updating tags
      message.updatedAt = new Date unless _tagIds
      message.socketId = socketId
      message.$save()

    $message.nodeify callback

  @action 'remove', (req, res, callback) ->
    {message} = req.get()
    conditions = _id: req.get('_id')
    message.socketId = req.get('socketId')
    message.remove (err) -> callback err, message

  @action 'clear', (req, res, callback) ->
    # Cancel message mail
    {_sessionUserId, _fromId, _toId, _roomId, _teamId, _storyId, _latestReadMessageId, socketId} = req.get()
    _fromId or= _toId

    # Clear the unread message number
    conditions =
      user: _sessionUserId
      team: _teamId

    update = unreadNum: 0
    update._latestReadMessageId = _latestReadMessageId if _latestReadMessageId

    switch
      when _roomId
        conditions.target = _roomId
        conditions.type = 'room'
      when _storyId
        conditions.target = _storyId
        conditions.type = 'story'
      when _fromId
        conditions.target = _fromId
        conditions.type = 'dms'
      else return callback null, ok: 1

    $notification = NotificationModel.findOneAsync conditions
    .then (notification) ->
      return unless notification
      notification.socketId = socketId
      notification[key] = val for key, val of update
      notification.$save()

    # Cancel emails
    if _roomId
      rmMailer.cancel _sessionUserId, _roomId, _teamId
    else if _storyId
      smMailer.cancel _sessionUserId, _storyId, _teamId
    else if _fromId and _teamId
      dmMailer.cancel _fromId, _sessionUserId, _teamId

    $notification.then (notification) -> ok: 1

    .nodeify callback

  @action 'afterClear', (req, res) ->
    # Broadcast team unread number
    {_sessionUserId, _teamId, _toId, _roomId, _latestReadMessageId, _storyId} = req.get()
    data = _teamId: _teamId, unread: {}, _latestReadMessageId: {}

    if _roomId
      data.unread[_roomId] = 0
      data._latestReadMessageId[_roomId] = _latestReadMessageId
    else if _toId
      data.unread[_toId] = 0
      data._latestReadMessageId[_toId] = _latestReadMessageId
    else if _storyId
      data.unread[_storyId] = 0
      data._latestReadMessageId[_storyId] = _latestReadMessageId

    res.broadcast "user:#{_sessionUserId}", "message:unread", data

  @action 'populateMessage', (req, res, message, callback) -> message.getPopulated callback

  @action 'search', (req, res, callback) -> messageSearcher.search req, res, callback

  @action 'repost', (req, res, callback) ->
    {_sessionUserId, message} = req.get()

    _message = message.toObject virtuals: false, getters: false
    _message = _.pick _message, [
      'body'
      'attachments'
      'displayType'
    ]

    repost = new MessageModel _message
    repost.creator = _sessionUserId
    repost.team = req.get('_teamId')

    switch
      when req.getParams('_roomId')
        repost.room = req.getParams('_roomId')
      when req.getParams('_toId')
        repost.to = req.getParams('_toId')
      when req.getParams('_storyId')
        repost.story = req.getParams('_storyId')
      else return callback(new Err('PARAMS_MISSING', '_roomId', '_toId', '_teamId', '_storyId'))

    repost.$save().nodeify callback

  @action 'reposts', (req, res, callback) ->
    {_messageIds} = req.get()
    async.mapSeries _messageIds, (_messageId, next) ->
      req.set '_id', _messageId
      messageController.call 'repost', req, res, next
    , callback

  ###*
   * Set related notification's text as new message's body
  ###
  @action 'afterUpdate', (req, res, message) ->
    {_sessionUserId} = req.get()
    # Do not update system message
    # Or message without change of body
    return if message.isSystem or not req.get('body')

    $notifications = Promise.resolve().then ->
      conditions =
        team: message._teamId
        _emitterId: message._id
      update =
        text: message.getAlert()
        creator: _sessionUserId
      NotificationModel.updateByOptionsAsync conditions, update

    .catch (err) -> logger.warn err.stack

  ###*
   * Set related notification's text as info-remove-message
  ###
  @action 'afterRemove', (req, res, message) ->
    {_sessionUserId} = req.get()
    return if message.isSystem

    $notifications = Promise.resolve().then ->
      conditions =
        team: message._teamId
        _emitterId: message._id
      update =
        text: '{{__info-remove-message}}'
        creator: _sessionUserId
      NotificationModel.updateByOptionsAsync conditions, update

    .catch (err) -> logger.warn err.stack

  ###*
   * Get meta infomation of url address
   * And update the body of message
  ###
  @action 'getUrlContent', (req, res, message) ->
    return if message.isSystem
    matches = message.body?.match /http(s)?:\/\/[\x21-\x7F]+/ig
    urls = matches?.slice(0,3) or [] # Up to three urls could be processed

    originUrls = message.urls or []

    isEqual = urls.length is originUrls.length and
      urls.every (elem, i) -> elem is originUrls[i]

    return if isEqual

    Promise.map urls, (url) ->

      MessageModel.getUrlContent url
      # Ignore the error caused by invalid url link
      .catch (err) -> logger.warn err.stack

    .then (attachments) ->
      attachments = attachments.filter (attachment) -> attachment
      message.attachments = attachments
      message.urls = urls
      message.socketId = undefined
      message.$save()

    .catch (err) -> logger.warn err.stack

  @action 'addSchedule', (req, res, message) ->
    remindAt = message.attachments?[0]?.data?.remindAt

    return unless remindAt and message.attachments?[0]?.category is 'calendar'

    schedule.addTask
      id: "calendar#{message._id}"
      action: 'calendar'
      executeAt: remindAt
      args: [message._id]

    .catch (err) -> logger.warn err.stack

  @action 'removeSchedule', (req, res, message) ->

    return unless message.attachments?[0]?.category is 'calendar'

    schedule.removeTask "calendar#{message._id}"

    .catch (err) -> logger.warn err.stack
