_ = require 'lodash'
Promise = require 'bluebird'
Err = require 'err1st'
limbo = require 'limbo'

app = require '../server'
{rmMailer, dmMailer, smMailer} = require '../mailers'

{
  NotificationModel
} = limbo.use 'talk'

module.exports = notificationController = app.controller 'notification', ->

  editableFields = ['unreadNum', 'isPinned', 'isMute', 'isHidden', '_latestReadMessageId']

  @mixin require './mixins/permission'

  @ensure '_teamId', only: 'read'
  @ensure '_targetId type _teamId', only: 'create'

  @least editableFields, only: 'update'

  @before 'isTeamMember', only: 'read'
  @before 'creatableNotification', only: 'create'
  @before 'editableNotification', only: 'update remove'

  @after 'populateNotification', only: 'create update'

  @action 'create', (req, res, callback) ->
    {_teamId, _sessionUserId} = req.get()

    options = _.pick req.get(), editableFields
    options = _.assign options,
      team: req.get '_teamId'
      user: req.get '_sessionUserId'
      target: req.get '_targetId'
      type: req.get 'type'
    options.text = req.get('text') if req.get('text')?

    NotificationModel.createByOptions options, callback

  @action 'read', (req, res, callback) ->
    {_sessionUserId, _teamId, limit} = req.get()

    options = _.assign {}, req.get(),
      user: _sessionUserId
      team: _teamId
      isHidden: false

    if limit
      options.isPinned = false
      $notifications = NotificationModel.findByOptionsAsync options

    else
      pinnedOptions = _.clone options
      pinnedOptions.isPinned = true
      pinnedOptions.limit = 99
      $pinnedNotifications = NotificationModel.findByOptionsAsync pinnedOptions

      unpinnedOptions = _.clone options
      unpinnedOptions.isPinned = false
      $unpinnedNotifications = NotificationModel.findByOptionsAsync unpinnedOptions

      $notifications = Promise.all [$pinnedNotifications, $unpinnedNotifications]

      .spread (pinnedNotifications = [], unpinnedNotifications = []) ->
        notifications = pinnedNotifications.concat unpinnedNotifications

    $notifications.nodeify callback

  @action 'update', (req, res, callback) ->
    {notification, socketId, unreadNum} = req.get()
    update = _.pick req.get(), editableFields
    notification[key] = val for key, val of update
    notification.socketId = socketId

    $notification = notification.$save()

    $cancelMail = $notification.then (notification) ->
      return unless unreadNum? and unreadNum is 0
      if notification.type is 'dms'
        dmMailer.cancel notification._targetId, notification._userId, notification._teamId
      else if notification.type is 'room'
        rmMailer.cancel notification._userId, notification._targetId, notification._teamId
      else if notification.type is 'story'
        smMailer.cancel notification._userId, notification._targetId, notification._teamId

    Promise.all [$notification, $cancelMail]
    .spread (notification) -> notification
    .nodeify callback

########################## HOOKS ##########################
#
  @action 'populateNotification', (req, res, notification, callback) ->
    notification.getPopulated callback
