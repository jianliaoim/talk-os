Err = require 'err1st'
moment = require 'moment'
Promise = require 'bluebird'
config = require 'config'
limbo = require 'limbo'
logger = require 'graceful-logger'
i18n = require 'i18n'
BaseMailer = require './base'
util = require '../util'

{
  UserModel
  MessageModel
  PreferenceModel
  NotificationModel
  RoomModel
} = limbo.use 'talk'

class RoomMessageMailer extends BaseMailer

  delay: 30 * 60 * 1000
  template: 'room-message'

  send: (_userId, _roomId, _teamId) ->
    _roomId = _roomId._id if _roomId instanceof RoomModel
    email = id: _userId + _roomId + _teamId
    self = this

    $preference = PreferenceModel.findOneAsync _id: _userId, 'emailNotification'

    if _roomId instanceof RoomModel
      $room = Promise.resolve _roomId
    else
      $room = RoomModel.findOneAsync _id: _roomId

    $user = UserModel.findOneAsync _id: _userId

    $notification = NotificationModel.findOneAsync
      team: _teamId
      user: _userId
      target: _roomId
      type: 'room'
    , 'unreadNum'

    Promise.all [$preference, $room, $user, $notification]

    .spread (preference, room, user, notification) ->

      return if preference?.emailNotification is false
      return unless room
      return unless user?.isRobot or user?.email
      return unless notification?.unreadNum > 0

      room.topic = '公告板' if room.isGeneral
      email.room = room
      email.to = user.email
      email.user = user

      {unreadNum} = notification

      if unreadNum < 20
        limit = unreadNum
        email.num = unreadNum
      else
        limit = 20
        email.num = '20+'
      options =
        isSystem: false
        limit: limit
      MessageModel.findMessagesFromRoomAsync _roomId, options

    # Construct messages
    .then (messages) ->
      return unless messages?.length
      messages.sort (x, y) -> if x._id > y._id then 1 else -1
      messages = messages.map (message) ->
        message.alert = i18n.replace message.getAlert()
        message.formatedDate = moment(new Date(message.createdAt)).format('HH:mm')
        return message
      email.messages = messages
      if email.user.isGuest
        email.clickUrl = email.room.guestUrl
      else
        email.clickUrl = util.buildTeamUrl messages[0].team, _roomId
      email.subject = "[简聊] 来自#{email.room?.topic}的新消息"
      self._sendByRender email

    .catch (err) -> logger.warn err.stack

  cancel: (_userId, _roomId, _teamId) ->
    id = _userId + _roomId + _teamId
    @_cancel id

module.exports = new RoomMessageMailer
