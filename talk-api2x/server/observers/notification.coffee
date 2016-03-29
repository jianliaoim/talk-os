Promise = require 'bluebird'
limbo = require 'limbo'
i18n = require 'i18n'
logger = require 'graceful-logger'
request = require 'request'
config = require 'config'
_ = require 'lodash'
moment = require 'moment-timezone'

{socket, apn, pusher, redis} = require '../components'

{
  NotificationModel
  PreferenceModel
  MemberModel
  DeviceTokenModel
  TeamModel
} = limbo.use 'talk'

_pushNotification = (notification) ->
  # @osv
  return notification
  # Pre-check situations that abandon push notification
  # 1. Creator himself
  # 2. Text is empty
  # 3. Muted notification and not mentioned
  if ("#{notification._userId}" is "#{notification._creatorId}") or
     (not notification.text?.length) or
     (notification.isMute and not notification.isRelated)
    return Promise.resolve(notification)

  $preference = PreferenceModel.findOneAsync
    _id: notification._userId
  , '_latestTeamId notifyOnRelated muteWhenWebOnline pushOnWorkTime timezone'

  $muteWhenWebOnline = $preference.then (preference) ->

    return false unless preference?.muteWhenWebOnline

    redis.getAsync "online_web_#{notification._userId}"

    .then (online) -> if online then true else false

  $needPush = Promise.all [$muteWhenWebOnline, $preference]

  .spread (muteWhenWebOnline, preference) ->
    return false if muteWhenWebOnline
    # Only push between 8 and 22
    if preference?.pushOnWorkTime
      hour = moment.tz(preference.timezone)?.hour?()
      return false unless hour >= 8 and hour < 22
    # Send notification when user was mentioned
    return true if notification.isRelated
    # Do not send notification when user was not mentioned and notifyOnRelated is true
    return false if preference?.notifyOnRelated and not notification.isRelated
    # Otherwise push notification
    true

  Promise.all [$needPush, $preference]

  .spread (needPush, preference) ->

    return notification unless needPush

    # --------------------- Begin sending notification ---------------------
    if notification.authorName
      $authorName = Promise.resolve notification.authorName
    else
      $authorName = MemberModel.findOneAsync
        team: notification._teamId
        user: notification._creatorId
        isQuit: false
      , 'prefs'
      .then (member) -> member?.prefs?.alias or notification.creator?.name

    # Get latest team id
    $_latestTeamId = $preference.then (preference) -> preference?._latestTeamId

    # Construct message alert
    $alert = Promise.all [$authorName, $_latestTeamId]

    .spread (authorName, _latestTeamId) ->
      alert = "#{authorName}: #{i18n.replace(notification.text)}"

      # Add team name when
      if "#{_latestTeamId}" is "#{notification._teamId}"
        $teamPrefix = Promise.resolve ''
      else
        $teamPrefix = TeamModel.findOneAsync _id: notification._teamId, 'name'
        .then (team) -> "[#{team?.name}] "

      $teamPrefix.then (teamPrefix) -> "#{teamPrefix}#{alert}"

    # Get device tokens
    $deviceTokens = DeviceTokenModel.findAsync
      user: notification._userId
      updatedAt: $gt: Date.now() - 7776000000

    # Get message badge, sum unread number of latest team
    $badge = $_latestTeamId.then (_latestTeamId) ->
      _teamId = _latestTeamId or notification._teamId
      NotificationModel.sumTeamUnreadNumAsync notification._userId, _teamId

    # Send notification
    Promise.all [$alert, $badge, $deviceTokens]

    .spread (alert, badge, deviceTokens = []) ->

      deviceTokens.map (deviceToken) ->
        {token, type} = deviceToken
        extra =
          'extra.intent_uri': 'intent:#Intent;component=com.teambition.talk/.activity.HomeActivity;end'
          'extra.notify_foreground': 0
          'extra.flow_control': 1
          "extra.badge": badge
          "extra.sound_uri": "android.resource://com.teambition.talk/raw/add"
        extra['extra._teamId'] = "#{notification._teamId}"
        extra['extra._targetId'] = "#{notification._targetId}"
        extra['extra.message_type'] = notification.type
        switch type
          when 'ios' then apn.push token, alert, badge, _.pick(extra, 'extra._targetId', 'extra.message_type', 'extra._teamId')
          when 'android' then pusher.baidu.send
            messages: JSON.stringify
              description: alert
              custom_content:
                badge: badge
            user_id: token
            message_type: 0
          when 'xiaomi'
            extra['extra.notify_effect'] = 2
            pusher.xiaomi.send
              description: alert
              pass_through: 1
              payload: alert
              registration_id: token
              title: '简聊'
              notify_id: 1
              notify_type: -1
              extra: extra
          when 'miui'
            extra['extra.notify_effect'] = 1
            pusher.xiaomi.send
              description: alert
              pass_through: 0
              payload: alert
              registration_id: token
              title: '简聊'
              notify_id: 1
              notify_type: -1
              extra: extra

NotificationSchema = NotificationModel.schema

NotificationSchema.pre 'save', (next) ->
  notification = this
  notification.creator or= notification._userId
  @_needChangeUpdateAt = ['text', 'isPinned', 'isHidden'].some (field) ->
    notification.isDirectModified field
  notification.updatedAt = new Date if @_needChangeUpdateAt
  next()

NotificationSchema.post 'save', (notification) ->
  notification.emit 'updated', notification

NotificationSchema.post 'updated', (notification) ->
  $notification = notification.getPopulatedAsync()
  $notification.then (notification) ->
    socket.broadcast "user:#{notification._userId}", 'notification:update', notification, notification.socketId
    if notification.needPush and notification.text?.length
      _pushNotification notification

NotificationSchema.post 'remove', (notification) ->
  socket.broadcast "user:#{notification._userId}", 'notification:remove', notification, notification.socketId
