Err = require 'err1st'
moment = require 'moment'
Promise = require 'bluebird'
config = require 'config'
BaseMailer = require './base'
util = require '../util'
{limbo, logger, i18n} = require '../components'

{
  PreferenceModel
  MessageModel
  UserModel
  TeamModel
  NotificationModel
} = limbo.use 'talk'

class DirectMessageMailer extends BaseMailer

  delay: 30 * 60 * 1000
  template: 'direct-message'

  send: (_fromId, _toId, _teamId) ->
    email = id: _fromId + _toId + _teamId
    self = this

    return if "#{_fromId}" is "#{_toId}"

    $preference = PreferenceModel.findOneAsync _id: _toId, 'emailNotification'

    $sender = UserModel.findOneAsync _id: _fromId

    $user = UserModel.findOneAsync _id: _toId

    $team = TeamModel.findOneAsync _id: _teamId

    $notification = NotificationModel.findOneAsync
      user: _toId
      team: _teamId
      target: _fromId
      type: 'dms'
    , 'unreadNum'

    Promise.all [$preference, $team, $sender, $user, $notification]

    .spread (preference, team, sender, user, notification) ->
      return if user?.isRobot or not user?.email or not sender
      return if preference?.emailNotification is false
      return unless team
      unreadNum = Number(notification?.unreadNum)
      return unless unreadNum > 0

      email.sender = sender
      email.user = user
      email.to = user.email
      email.team = team

      options =
        isSystem: false
        limit: if unreadNum < 30 then unreadNum else 30
      MessageModel.findMessagesWithUserAsync _fromId, _toId, _teamId, options

    .then (messages = []) ->
      return unless messages.length
      messages.sort (x, y) -> if x._id > y._id then 1 else -1
      messages = messages.map (message) ->
        message.alert = i18n.replace message.getAlert()
        message.formatedDate = moment(new Date(message.createdAt)).format('HH:mm')
        return message
      email.messages = messages
      email.clickUrl = util.buildTeamUrl email.team._id, null, email.sender?._id
      email.subject = "[简聊] #{email.sender?.name}给你发送了新消息"
      self._sendByRender email

    .catch (err) -> logger.warn err.stack

  cancel: (_fromId, _toId, _teamId) ->
    id = _fromId + _toId + _teamId
    @_cancel id

module.exports = new DirectMessageMailer
