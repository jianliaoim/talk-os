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
  StoryModel
} = limbo.use 'talk'

class StoryMessageMailer extends BaseMailer

  delay: 30 * 60 * 1000
  template: 'story-message'

  send: (_userId, _storyId, _teamId) ->
    _storyId = _storyId._id if _storyId instanceof StoryModel

    email = id: _userId + _storyId + _teamId

    self = this

    $preference = PreferenceModel.findOneAsync _id: _userId, 'emailNotification'

    if _storyId instanceof StoryModel
      $story = Promise.resolve _storyId
    else
      $story = StoryModel.findOneAsync _id: _storyId

    $user = UserModel.findOneAsync _id: _userId

    $notification = NotificationModel.findOneAsync
      team: _teamId
      user: _userId
      target: _storyId
      type: 'story'
    , 'unreadNum'

    Promise.all [$preference, $story, $user, $notification]

    .spread (preference, story, user, notification) ->
      return if preference?.emailNotification is false
      return unless story
      return unless user?.isRobot or user?.email
      return unless notification?.unreadNum > 0

      email.story = story
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
        _storyId: _storyId
      MessageModel.findByOptionsAsync options

    # Construct messages
    .then (messages) ->
      return unless messages?.length
      messages.sort (x, y) -> if x._id > y._id then 1 else -1
      messages = messages.map (message) ->
        message.alert = i18n.replace message.getAlert()
        message.formatedDate = moment(new Date(message.createdAt)).format('HH:mm')
        return message
      email.messages = messages
      email.clickUrl = util.buildStoryUrl _teamId, _storyId
      email.subject = "[简聊] 来自 #{email.story?.title?[0..10] or ''} 的讨论"
      self._sendByRender email

    .catch (err) -> logger.warn err.stack

  cancel: (_userId, _storyId, _teamId) ->
    id = _userId + _storyId + _teamId
    @_cancel id

module.exports = new StoryMessageMailer
