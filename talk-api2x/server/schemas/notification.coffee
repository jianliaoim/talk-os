###*
 * Save user's unread number, latest read message id and pinnedAt property
 * db.notifications.ensureIndex({user: 1, team: 1, isHidden: 1, isPinned: 1, updatedAt: -1}, {background: true})
 * db.notifications.ensureIndex({target: 1, team: 1, user: 1, type: 1}, {unique: true, background: true})
 * db.notifications.ensureIndex({_emitterId: 1, team: 1}, {background: true})
###

mongoose = require 'mongoose'
Err = require 'err1st'
_ = require 'lodash'
Promise = require 'bluebird'
{Schema} = mongoose

module.exports = NotificationSchema = new Schema
  user: type: Schema.Types.ObjectId, ref: 'User'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  target: type: Schema.Types.ObjectId
  type: type: String  # Target type
  creator: type: Schema.Types.ObjectId, ref: 'User'
  text: type: String, default: '', set: (text) -> if text?.length > 100 then text[0...100] else text
  unreadNum: type: Number, default: 0, set: (unreadNum) ->
    @oldUnreadNum = @unreadNum or 0
    unreadNum
  isPinned: type: Boolean, default: false, set: (isPinned) ->
    if isPinned
      @pinnedAt = new Date
    else
      @pinnedAt = undefined
    return isPinned
  pinnedAt: type: Date
  authorName: type: String
  isMute: type: Boolean, default: false
  isHidden: type: Boolean, default: false, set: (isHidden) ->
    @isPinned = false if isHidden
    isHidden
  _emitterId: type: Schema.Types.ObjectId
  _latestReadMessageId: type: Schema.Types.ObjectId
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

NotificationSchema.virtual '_userId'
  .get -> @user?._id or @user
  .set (_id) -> @user = _id

NotificationSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

NotificationSchema.virtual '_targetId'
  .get -> @target?._id or @target
  .set (_id) -> @target = _id

NotificationSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

NotificationSchema.virtual 'oldUnreadNum'
  .get -> @_oldUnreadNum
  .set (@_oldUnreadNum) -> @_oldUnreadNum

# ============================== Methods ==============================

NotificationSchema.methods.getPopulated = (callback) ->
  self = this
  unless self.$populating
    # Populate target field
    switch self.type
      when 'room' then modelName = 'Room'
      when 'dms' then modelName = 'User'
      when 'story' then modelName = 'Story'

    self.$populating = Promise.promisify self.populate
    .call self, [
      path: 'target'
      model: modelName
    ,
      path: 'creator'
    ]

  self.$populating.nodeify callback

# ============================== Statics ==============================

NotificationSchema.statics.findByOptions = (options, callback) ->
  options.limit or= 10
  options.sort or= updatedAt: -1

  conditions = _.pick options, 'user', 'team', 'isHidden', 'isPinned'
  conditions.updatedAt = $lt: options.maxUpdatedAt if options.maxUpdatedAt

  $notifications = @_buildQuery.call(this, conditions, options).execAsync()

  $notifications = $notifications.map (notification) ->
    notification.getPopulatedAsync()
  .filter (notification) ->
    switch notification.type
      when 'room' then return notification.target?.isArchived is false
      else return notification.target?._id

  $notifications.nodeify callback

NotificationSchema.statics.updateByOptions = (conditions, update, callback) ->
  NotificationModel = this
  $notifications = NotificationModel.findAsync conditions

  $notifications = $notifications.map (notification) ->
    for key, val of update
      notification[key] = val
    notification.$save()

  $notifications.nodeify callback

NotificationSchema.statics.createByOptions = (options, callback) ->
  unless options.user and options.team and options.target and options.type
    return callback(new Err('PARAMS_MISSING', 'user team target type'))

  conditions =
    user: options.user
    target: options.target
    team: options.team
    type: options.type

  NotificationModel = this

  $notification = NotificationModel.findOneAsync conditions

  $notification = $notification.then (notification) ->
    unless notification
      notification = new NotificationModel

    for key, val of options
      if key is 'unreadNum' and val?.$inc
        notification.unreadNum += 1
      else
        notification[key] = val
    notification.isHidden = false
    # Reset authorName
    notification.authorName = undefined unless options.authorName
    notification.$save()

  $notification.nodeify callback

###*
 * Remove notifications and broadcast messages
 * @param  {Object}   options - Conditions
 * @param  {Function} callback
###
NotificationSchema.statics.removeByOptions = (options, callback) ->
  unless options.target and options.team
    return callback(new Err('PARAMS_MISSING', 'target team'))

  NotificationModel = this

  conditions =
    target: options.target
    team: options.team
  conditions.user = options.user if options.user
  conditions.type = options.type if options.type

  $notifications = NotificationModel.findAsync conditions

  $notifications.map (notification) ->
    notification.$remove()

  .nodeify callback

###*
 * Sum team unread number
 * @param  {ObjectId}   _userId  User id
 * @param  {ObjectId}   _teamId  Team id
 * @param  {Function} callback [description]
 * @todo Cache it
###
NotificationSchema.statics.sumTeamUnreadNum = (_userId, _teamId, callback) ->
  @find
    user: _userId
    team: _teamId
    isHidden: false
    unreadNum: $gt: 0
    isMute: false
  , 'unreadNum'
  , (err, notifications = []) ->
    unreadNum = notifications.reduce (totalUnread, notification) ->
      totalUnread += notification.unreadNum if notification?.unreadNum
      totalUnread
    , 0
    callback err, unreadNum

NotificationSchema.statics.findUnreadNums = (_userId, _teamId, callback) ->
  @find
    user: _userId
    team: _teamId
    isHidden: false
    unreadNum: $gt: 0
  , 'target unreadNum isMute'
  , (err, notifications = []) ->
    unreadNums = {}
    for notification in notifications
      unreadNums["#{notification._targetId}"] = notification.unreadNum
    callback err, unreadNums

NotificationSchema.statics.findLatestReadMessageIds = (_userId, _teamId, callback) ->
  @find
    user: _userId
    team: _teamId
    _latestReadMessageId: $ne: null
  , 'target _latestReadMessageId'
  , (err, notifications = []) ->
    _latestReadMessageIds = {}
    for notification in notifications
      _latestReadMessageIds["#{notification._targetId}"] = notification._latestReadMessageId
    callback err, _latestReadMessageIds

NotificationSchema.statics.findPinnedAts = (_userId, _teamId, callback) ->
  @find
    user: _userId
    team: _teamId
    isPinned: true
  , 'target isPinned pinnedAt'
  , (err, notifications = []) ->
    pinnedAts = {}
    for notification in notifications
      pinnedAts["#{notification._targetId}"] = notification.pinnedAt
    callback err, pinnedAts
