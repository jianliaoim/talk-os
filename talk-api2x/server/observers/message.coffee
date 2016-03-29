mongoose = require 'mongoose'
request = require 'request'
Promise = require 'bluebird'
Err = require 'err1st'
_ = require 'lodash'
serviceLoader = require 'talk-services'

config = require 'config'
limbo = require 'limbo'
util = require '../util'
{socket, i18n, apn, pusher, logger} = require '../components'

{
  UserModel
  MemberModel
  TeamModel
  DeviceTokenModel
  PreferenceModel
  MessageModel
  NotificationModel
  UsageModel
  SearchMessageModel
} = limbo.use 'talk'

class MessageSender

  constructor: (@message) ->
    @message = new MessageModel @message unless @message instanceof mongoose.Model
    @$message = @message.getPopulatedAsync()

  ################################ Public ################################
  # Broadcast message to the clients by websocket channels
  broadcastMessage: (event = "message:create") ->
    self = this
    {message, $message} = this
    {socketId} = message
    {_roomId, _teamId, _toId, _creatorId} = message

    $message.then (message) ->
      if _roomId
        message = message.toJSON() if message.toJSON?
        self._getRoomMembers _roomId
        .then (members) ->
          channels = members.map (member) -> "user:#{member._userId}"
          socket.broadcast channels, event, message, socketId

      else if message.story
        channels = message.story._memberIds?.map (_memberId) -> "user:#{_memberId}"
        socket.broadcast channels, event, message, socketId

      else if _toId and _teamId
        channels = ["user:#{_toId}", "user:#{_creatorId}"]
        socket.broadcast channels, event, message, socketId

  # Send email to the recievers
  sendMail: ->
    {message, $message} = this
    {_creatorId, _toId, _teamId, _roomId, _storyId} = message
    {dmMailer, rmMailer, smMailer} = require '../mailers'
    self = this

    if _roomId
      if message.mentions.length > 0
        _mentionIds = message.mentions.map (mentionId) -> mentionId.toString()
      else return

      $message.then (message) ->

        Promise.map _mentionIds, (_mentionId) ->
          return if _mentionId is "#{message._creatorId}"
          rmMailer.send _mentionId, message.room, message._teamId

      .catch (err) -> logger.warn err.stack if err

    else if _storyId
      if message.mentions.length > 0
        _mentionIds = message.mentions.map (mentionId) -> mentionId.toString()
      else return

      $message.then (message) ->

        Promise.map _mentionIds, (_mentionId) ->
          return if _mentionId is "#{message._creatorId}"
          smMailer.send _mentionId, message.story, message._teamId

      .catch (err) -> logger.warn err.stack if err

    else if _toId and _teamId
      dmMailer.send _creatorId, _toId, _teamId

  ###*
   * Send a notification from talkai to the receiver
   * when the mentioned user is not in the room or story
   * @return {Promise} Null
  ###
  checkMentions: ->
    self = this

    {message, $message} = this

    return unless message._roomId

    $talkai = serviceLoader.getRobotOf 'talkai'

    # Get mention ids
    $_mentionIds = self.$message.then (message) ->
      {room} = message
      # Should not send notification when the room is private
      return unless room and not room.isPrivate

      return unless message.mentions.length

      _mentionIds = message.mentions.map (mentionId) -> "#{mentionId}"

    # Get room members
    $_roomUserIds = self._getRoomMembers message._roomId

    .then (roomMembers) -> _userIds = roomMembers.map (member) -> "#{member._userId}"

    # Filter members not in this room
    $_nonMemberIds = Promise.all [$_mentionIds, $_roomUserIds]

    .spread (_mentionIds, _roomUserIds) ->

      return [] unless _mentionIds?.length

      _mentionIds.filter (_mentionId) -> "#{_mentionId}" not in _roomUserIds

    # Get alias of creator
    $creator = MemberModel.findOne
      user: message._creatorId
      team: message._teamId
      isQuit: false
    , 'prefs user'
    .populate 'user'
    .execAsync()
    .then (member) ->
      return unless member?.user
      user = member.user
      user.prefs = member.prefs
      user

    # Send message from talkai
    $_nonMemberIds.map (_mentionId) ->

      # Get message body
      $body = Promise.all [$message, $creator]

      .spread (message, creator) ->

        PreferenceModel.findOneAsync _id: _mentionId

        .then (preference) ->
          lang = preference?.language or 'zh'
          i18n.fns(lang).mentionOutOfRoom creator, message.room

      Promise.all [$message, $body, $talkai]

      .spread (message, body, talkai) ->
        mentionMessage = new MessageModel
          creator: talkai._id
          to: _mentionId
          team: message._teamId
          body: body
        attachment =
          category: 'message'
          data: message
        mentionMessage.attachments = [attachment]
        mentionMessage.$save()

    .catch (err) -> logger.warn err.stack

  isRelated: (_userId) ->
    {message} = this
    return true if "#{message._toId}" is "#{_userId}"

    if message.mentions.length > 0
      _mentionIds = message.mentions.map (mentionId) -> mentionId.toString()
      return true if "#{_userId}" in _mentionIds

    false

  ################################ Protected ################################

  _getRoomMembers: (_roomId) ->
    return @$_members if @$_members
    @$_members = MemberModel.findAsync
      room: _roomId
      isQuit: false
    , 'user _userId prefs'

  _getCreatorPrefs: (_creatorId, _teamId, _roomId) ->
    return @$_creatorPrefs if @$_creatorPrefs
    @$_creatorPrefs = @_getUserPrefs _creatorId, _teamId, _roomId

  _getUserPrefs: (_userId, _teamId, _roomId) ->
    conditions =
      user: _userId
      team: _teamId
      isQuit: false

    MemberModel.findOneAsync conditions
    .then (member) -> member?.prefs or {}

_createNotification = (message, options) ->
  _options = _.assign
    team: message._teamId
    creator: message._creatorId
    text: message.getAlert()
    updatedAt: new Date
    _emitterId: message._id
    authorName: message.authorName
  , options

  unless message.isSystem
    _options.unreadNum = $inc: 1
    _options.needPush = true

  if "#{_options.user}" is "#{message._creatorId}"
    _options.unreadNum = 0
    _options._latestReadMessageId = message._id

  NotificationModel.createByOptionsAsync _options

# Bind listeners on message schema
MessageSchema = MessageModel.schema

MessageSchema.pre 'save', (next) ->
  message = this
  # User should not send message to himself
  return next(new Err('INVALID_TARGET', "_toId #{@_toId}")) if "#{@_creatorId}" is "#{@_toId}"
  message.displayType = 'text' unless message.displayType in ['markdown', 'text']
  message._wasNew = message.isNew
  message._wasModified = ['body', 'attachments', 'tags'].some (field) -> message.isDirectModified field
  message.hasTag = if message.tags?.length then true else false

  $setMentions = message.setMentionsAsync()

  if message.isNew
    $setIntegration = message.setIntegrationAsync()
  else
    $setIntegration = Promise.resolve()

  Promise.all [$setMentions, $setIntegration]
  .then -> next()
  .catch next

MessageSchema.post 'save', (message) ->
  if message._wasNew
    message.emit 'create', message
  else if message._wasModified
    message.needSearch = true
    message.emit 'updated', message

MessageSchema.post 'create', (message) ->
  sender = new MessageSender message
  {socketId} = message
  sender.$message.then (message) -> message.index()

  # Broadcast message and create notifications
  # If it is a system message
  # Do not increase unread message number
  if message._roomId
    $broadcast = sender.$message.then (message) ->
      msgObj = message.toJSON?() or message
      sender._getRoomMembers message._roomId
      .map (member) ->
        return unless member._userId
        _msgObj = _.clone msgObj
        _msgObj.room?.prefs = member.prefs

        $notification = _createNotification message,
          user: member._userId
          target: message._roomId
          type: 'room'
          isRelated: sender.isRelated member._userId

        $notification.then (notification) ->
          _msgObj.notification = notification?.toJSON() if notification
          channel = "user:#{member._userId}"
          socket.broadcast channel, 'message:create', _msgObj, socketId

  else if message._storyId
    $broadcast = sender.$message.then (message) ->
      msgObj = message.toJSON?() or message
      message.story._memberIds?.map (_memberId) ->
        return unless _memberId
        $notification = _createNotification message,
          user: _memberId
          target: message._storyId
          type: 'story'
          isRelated: sender.isRelated _memberId

        $notification = $notification.then (notification) ->
          _msgObj = _.clone msgObj
          _msgObj.notification = notification?.toJSON() if notification
          socket.broadcast "user:#{_memberId}", 'message:create', _msgObj, socketId

  else if message._toId
    $broadcast = sender.$message.then (message) ->
      msgObj = message.toJSON?() or message

      $creatorNotification = _createNotification message,
        user: message._creatorId
        target: message._toId
        type: 'dms'
        isRelated: sender.isRelated message._creatorId

      $touserNotification = _createNotification message,
        user: message._toId
        target: message._creatorId
        type: 'dms'
        isRelated: sender.isRelated message._toId

      $creatorNotification = $creatorNotification.then (notification) ->
        _msgObj = _.clone msgObj
        _msgObj.notification = notification?.toJSON() if notification
        socket.broadcast "user:#{message._creatorId}", 'message:create', _msgObj, socketId

      $touserNotification = $touserNotification.then (notification) ->
        _msgObj = _.clone msgObj
        _msgObj.notification = notification?.toJSON() if notification
        socket.broadcast "user:#{message._toId}", 'message:create', _msgObj, socketId

      Promise.all [$creatorNotification, $touserNotification]

  else return logger.warn(new Err("Invalid message", message))

  $broadcast.catch (err) -> logger.warn err.stack

  # Send message to outgoing service
  # Send message to receiver services
  # Ignore system messages
  return if message.isSystem

  sender.checkMentions()

  $broadcast.then (notification) -> sender.sendMail()

# Save usage
MessageSchema.post 'create', (message) ->
  return if message.isSystem
  # Save file usage
  $fileUsage = Promise.resolve(message).then (message) ->
    totalSize = 0
    message.attachments?.forEach (attachment) ->
      return unless attachment?.category is 'file' and attachment?.data?.fileSize
      totalSize += attachment.data.fileSize
    return unless totalSize > 0
    UsageModel.incrAsync message._teamId, 'file', totalSize

  # Save userMessage usage
  $userMessageUsage = Promise.resolve(message).then (message) ->
    return if message.integration
    UsageModel.incrAsync message._teamId, 'userMessage', 1

  # Save inteMessage usage
  $inteMessageUsage = Promise.resolve(message).then (message) ->
    return unless message.integration
    UsageModel.incrAsync message._teamId, 'inteMessage', 1

  Promise.all [$fileUsage, $userMessageUsage, $inteMessageUsage]

  .catch (err) -> logger.warn err.stack

MessageSchema.post 'updated', (message) ->
  sender = new MessageSender message
  sender.broadcastMessage "message:update"
  if message.needSearch
    sender.$message.then (message) -> message.index()

MessageSchema.post 'remove', (message) ->
  sender = new MessageSender message
  sender.broadcastMessage "message:remove"
  sender.$message.then (message) -> message.unIndex()
