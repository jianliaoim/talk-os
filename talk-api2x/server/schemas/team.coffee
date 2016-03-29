###*
 * Indexes:
 * - db.teams.ensureIndex({sourceId: 1, source: 1}, {unique: true, sparse: true, background: true})
 * - db.teams.ensureIndex({inviteCode: 1}, {unique: true, sparse: true, background: true})
 * - db.teams.ensureIndex({shortName: 1}, {unique: true, sparse: true, background: true})
###
{Schema} = require 'mongoose'
Promise = require 'bluebird'
async = require 'async'
Err = require 'err1st'
_ = require 'lodash'
logger = require 'graceful-logger'
serviceLoader = require 'talk-services'

redis = require '../components/redis'
makestatic = require './plugins/makestatic'

util = require '../util'

colors = [
  'grape'
  'blueberry'
  'ocean'
  'mint'
  'tea'
  'ink'
]

# Map old colors to new colors
colorAlias =
  blue: 'blueberry'
  grass: 'tea'
  purple: 'grape'
  cyan: 'mint'

_colorRandom = -> util.arrRandom(colors, 1)[0]

_getColor = (val) ->
  return val if val in colors
  return colorAlias[val] if colorAlias[val]
  return 'ocean'

module.exports = TeamSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User', required: true
  name: type: String, required: true
  description: type: String
  source: String
  sourceId: String
  sourceName: type: String, get: (val) -> val or (if @source then @name)
  color: type: String, default: 'ocean', get: _getColor
  inviteCode: type: String, default: util.genInviteCode
  nonJoinable: type: Boolean, default: false
  logoUrl: type: String
  shortName: type: String
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

TeamSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

TeamSchema.virtual 'inviteUrl'
  .get -> util.buildInviteUrl @inviteCode

TeamSchema.virtual 'sourceUrl'
  .get -> if @source is 'teambition' then util.buildTbOrgzUrl(@sourceId) else undefined

TeamSchema.virtual 'hasVisited'
  .get -> @_hasVisited
  .set (@_hasVisited) -> @_hasVisited

TeamSchema.virtual 'rooms'
  .get -> @_rooms
  .set (@_rooms) -> @_rooms

TeamSchema.virtual 'members'
  .get -> @_members
  .set (@_members) -> @_members

TeamSchema.virtual 'unread'
  .get -> @_unread
  .set (@_unread) -> @_unread

TeamSchema.virtual 'hasUnread'
  .get ->
    return @_hasUnread if @_hasUnread?
    if @_unread then true else false
  .set (@_hasUnread) -> @_hasUnread

TeamSchema.virtual 'latestMessages'
  .get -> @_latestMessages
  .set (@_latestMessages) -> @_latestMessages

TeamSchema.virtual 'prefs'
  .get -> @_prefs
  .set (@_prefs) -> @_prefs

TeamSchema.virtual 'signCode'
  .get -> @_signCode
  .set (@_signCode) -> @_signCode

TeamSchema.virtual 'signCodeExpireAt'
  .get -> @_signCodeExpireAt
  .set (@_signCodeExpireAt) -> @_signCodeExpireAt

TeamSchema.virtual 'invitations'
  .get -> @_invitations
  .set (@_invitations) -> @_invitations

TeamSchema.virtual 'shortUrl'
  .get -> if @shortName then util.buildShortTeamUrl(@shortName) else undefined

#################################### Methods ####################################
#
TeamSchema.methods.addMember = (_userId, options = {}, callback = ->) ->
  if arguments.length is 2 and typeof options is 'function'
    callback = options
    options = {}

  UserModel = @model 'User'
  MemberModel = @model 'Member'
  RoomModel = @model 'Room'
  team = this

  if _userId instanceof UserModel
    $user = Promise.resolve _userId
  else
    $user = UserModel.findOneAsync _id: _userId
    .then (user) ->
      throw new Err('OBJECT_MISSING', "user #{_userId}") unless user
      user

  ###*
   * Add user to this team
   * @param  {Model} user - User model
   * @return {Model} member - Member model of this team and user
  ###
  $teamMember = $user.then (user) ->
    {role} = options
    role or= 'member'
    conditions =
      team: team._id
      user: user._id
    update = role: role
    update.role = 'owner' if "#{user._id}" is "#{team._creatorId}"
    MemberModel.joinAsync conditions, update

  $roomUser = $user.then (user) ->
    RoomModel.findOneAsync
      team: team._id
      isGeneral: true
    .then (room) ->
      throw new Err('OBJECT_MISSING', "General room of team #{team._id}") unless room
      room.addMemberAsync user

  Promise.all [$user, $teamMember, $roomUser]

  .spread (user, teamMember, roomUser) ->
    user._teamId = team._id
    user.team = team
    user.role = teamMember.role
    user.prefs = teamMember.prefs
    user

  .nodeify callback

TeamSchema.methods.removeMember = (_userId, callback) ->
  MemberModel = @model 'Member'
  RoomModel = @model 'Room'
  UserModel = @model 'User'
  GroupModel = @model 'Group'
  StoryModel = @model 'Story'
  team = this

  $rooms = RoomModel.findAsync team: team._id, '_id'

  $removeMembers = $rooms.then (rooms) ->
    _roomIds = rooms.map (room) -> room._id
    MemberModel.updateAsync
      user: _userId
      $or: [
        team: team._id
      ,
        room: $in: _roomIds
      ]
    ,
      isQuit: true
      quitAt: new Date
    ,
      multi: true

  $removeGroupMembers = GroupModel.updateAsync
    team: team._id
  ,
    $pull: members: _userId
  ,
    multi: true

  $removeStoryMembers = StoryModel.updateAsync
    team: team._id
  ,
    $pull: members: _userId
  ,
    multi: true

  Promise.all [$removeMembers, $removeGroupMembers, $removeStoryMembers]
  .spread -> team
  .nodeify callback

TeamSchema.methods.updatePrefs = (_userId, prefs = {}, callback) ->
  MemberModel = @model 'Member'
  team = this

  MemberModel.findOneAsync
    team: team._id
    user: _userId
    isQuit: false

  .then (member) ->
    throw new Err('MEMBER_CHECK_FAIL', "team #{team.name}") unless member

    member.prefs or= {}
    for key, val of prefs
      member.prefs[key] = val

    new Promise (resolve, reject) ->
      member.save (err, member) ->
        return reject(err) if err
        resolve member

  .then (member) ->
    team.prefs = member.prefs
    team

  .nodeify callback

TeamSchema.methods.attachMembers = (callback) ->
  MemberModel = @model 'Member'
  team = this

  Promise.resolve().then ->
    MemberModel.find
      team: team._id
      isQuit: false
    .populate 'user'
    .exec()

  .then (members) ->
    team.members = members.map (member) ->
      _user = member.user
      _user?.prefs = member.prefs
      _user?.role = member.role
      _user
    .filter (user) -> user and not user.isGuest

    team

  .nodeify callback

TeamSchema.methods.attachInvitations = (callback) ->
  InvitationModel = @model 'Invitation'
  team = this
  InvitationModel.find team: team._id, (err, invitations) ->
    team.invitations = invitations
    callback err, team

TeamSchema.methods.attachRooms = (callback) ->
  RoomModel = @model 'Room'
  team = this

  Promise.resolve().then ->
    RoomModel.find
      team: team._id
      isArchived: false
    .sort _id: -1
    .exec()

  .then (rooms) ->
    team.rooms = rooms
    team

  .nodeify callback

###*
 * Add prefs property on team object
 * @param  {ObjectId} _userId - User id
 * @param  {Function} callback
 * @return {Promise} team - Team model
###
TeamSchema.methods.attachPrefs = (_userId, callback) ->
  team = this

  _attachPrefsFromMember = ->
    MemberModel = team.model 'Member'
    MemberModel.findOneAsync
      user: _userId
      team: team._id
      isQuit: false
    .then (member) ->
      throw new Err('MEMBER_CHECK_FAIL', "team #{team.name}") unless member
      team.prefs = member.prefs
      team

  Promise.resolve()
  .then ->
    if team.members?
      team.members.forEach (user) ->
        if "#{_userId}" is "#{user._id}"
          team.prefs = user.prefs
      $team = team
    else
      $team = _attachPrefsFromMember()
    $team

  .nodeify callback

TeamSchema.methods.attachLatestMessages = (_userId, callback) ->
  team = this
  {rooms, members} = team
  MessageModel = team.model 'Message'

  $roomMessages = Promise.map rooms, (room) ->
    return if room.isQuit
    options = isSystem: false
    MessageModel.findLatestMessageFromRoomAsync room._id, options

  $directMessages = Promise.map members, (user) ->
    return if "#{user._id}" is "#{_userId}"
    options = isSystem: false
    MessageModel.findLatestMessageWithUserAsync user._id, _userId, team._id, options

  Promise.all [$roomMessages, $directMessages]

  .then ([roomMessages, directMessages]) ->
    [].concat(roomMessages, directMessages)
      .filter (m) -> m
      .sort (x, y) -> if y._id > x._id then 1 else -1

  .then (latestMessages) ->
    team.latestMessages = latestMessages
    team

  .nodeify callback

TeamSchema.methods.attachUnreadNums = (_userId, callback = ->) ->
  team = this
  NotificationModel = team.model 'Notification'

  NotificationModel.findAsync
    user: _userId
    team: team._id
    isHidden: false
    unreadNum: $gt: 0
  , 'target unreadNum isMute'

  .then (notifications) ->
    unreadMap = {}
    for notification in notifications
      unreadMap["#{notification._targetId}"] = notification

    team.members?.forEach (user) -> user.unread = unreadMap["#{user._id}"]?.unreadNum or 0

    team.rooms?.forEach (room) ->
      return if room.isQuit or room.isArchived
      room.unread = unreadMap["#{room._id}"]?.unreadNum or 0

    hasUnread = false
    if _.values(unreadMap).length
      teamUnread = _.values(unreadMap).reduce (sum, cur) ->
        return sum unless cur?.unreadNum
        hasUnread = true
        return sum if cur.isMute
        sum += cur.unreadNum
        sum
      , 0
    else teamUnread = 0

    team.unread = teamUnread
    team.hasUnread = hasUnread
    team

  .nodeify callback

TeamSchema.methods.attachSignCode = (callback = ->) ->
  team = this
  key = "signcode:#{team._id}"

  redis.multi()
  .get key
  .ttl key
  .exec (err, data = []) ->
    return callback(err) if err
    [signCode, ttl] = data
    if signCode
      team.signCode = signCode
      team.signCodeExpireAt = new Date(Date.now() + (ttl or 0) * 1000)
      return callback null, team
    team.refreshSignCode callback

TeamSchema.methods.refreshSignCode = (callback = ->) ->
  team = this
  key = "signcode:#{team._id}"
  expire = 86400 * 7
  team.signCode = signCode = util.genInviteCode()
  team.signCodeExpireAt = new Date(Date.now() + expire * 1000)
  redis.setex key, expire, signCode, (err) ->
    callback err, team

TeamSchema.methods.joinBySignCode = (_userId, signCode, callback) ->
  team = this
  key = "signcode:#{team._id}"
  redis.get key, (err, _signCode) ->
    return callback(new Err('INVALID_INVITECODE')) unless signCode is _signCode
    team.addMember _userId, callback

TeamSchema.methods.setMemberRole = (_userId, role, callback = ->) ->
  MemberModel = @model 'Member'
  MemberModel.update
    user: _userId
    team: @_id
  ,
    role: role
  , callback

###*
 * 邀请用户加入团队，如果用户存在则直接接入，否则仅创建一条邀请记录
 * @param  {Object} conditions 邀请条件
 * @return {Model} invitee 被邀请者 user 对象或 invitation 对象
###
TeamSchema.methods.invite = (conditions, callback = ->) ->
  UserModel = @model 'User'
  InvitationModel = @model 'Invitation'
  team = this
  {email, mobile, key} = conditions
  return callback(new Err('PARAMS_MISSING', 'email, mobile, key')) unless email or mobile or key

  if mobile
    $invitee = UserModel.findOneAsync phoneForLogin: mobile
  else if email
    $invitee = UserModel.findOneAsync emailForLogin: email
  else if key
    [refer, openIds...] = key.split('_')
    openId = openIds.join '_'
    $invitee = UserModel.findOneAsync
      "unions.refer": refer
      "unions.openId": openId

  $invitee.then (invitee) ->
    if invitee  # 如用户存在，则直接加入团队
      team.addMemberAsync invitee, conditions
    else
      conditions.team = team._id
      InvitationModel.inviteAsync conditions

  .then (invitee) ->
    invitee.team = team
    invitee.role or= 'member'
    invitee

  .nodeify callback

TeamSchema.methods.createJoinMessage = (conditions, callback = ->) ->
  MessageModel = @model 'Message'
  RoomModel = @model 'Room'
  message = new MessageModel conditions
  message._teamId = @_id
  message.creator or= conditions._userId
  message.body = '{{__info-join-team}}'
  message.isSystem = true
  message.icon = 'join-team'

  if message._roomId
    $message = message.$save()
  else
    $message = RoomModel.findOneAsync
      team: message._teamId
      isGeneral: true
    .then (room) ->
      throw new Err('OBJECT_MISSING', 'general room') unless room?._id
      message._roomId = room._id
      message.$save()

  $message.nodeify callback

TeamSchema.methods.createLeaveMessage = (conditions, callback = ->) ->
  MessageModel = @model 'Message'
  RoomModel = @model 'Room'
  message = new MessageModel conditions
  message._teamId = @_id
  message.creator or= conditions._userId
  message.body = '{{__info-leave-team}}'
  message.isSystem = true
  message.icon = 'leave-team'

  if message._roomId
    $message = message.$save()
  else
    $message = RoomModel.findOneAsync
      team: message._teamId
      isGeneral: true
    .then (room) ->
      throw new Err('OBJECT_MISSING', 'general room') unless room?._id
      message._roomId = room._id
      message.$save()

  $message.nodeify callback

TeamSchema.methods.attachLatestReadMessageIds = (_userId, callback = ->) ->
  team = this
  {rooms, members} = team
  NotificationModel = @model 'Notification'
  NotificationModel.findLatestReadMessageIds _userId, team._id, (err, _latestReadMessageIds = {}) ->
    return callback err, team if err
    rooms.forEach (room) -> room._latestReadMessageId = _latestReadMessageIds["#{room._id}"] or null
    members.forEach (member) -> member._latestReadMessageId = _latestReadMessageIds["#{member._id}"] or null
    callback err, team

TeamSchema.methods.attachPinnedAt = (_userId, callback = ->) ->
  NotificationModel = @model 'Notification'
  team = this
  NotificationModel.findPinnedAts _userId, team._id, (err, pinnedAts = {}) ->
    team.rooms?.forEach (room) ->
      pinnedAt = pinnedAts["#{room._id}"] if pinnedAts["#{room._id}"]
      room.pinnedAt = pinnedAt if pinnedAt
    team.members?.forEach (user) ->
      pinnedAt = pinnedAts["#{user._id}"] if pinnedAts["#{user._id}"]
      user.pinnedAt = pinnedAt if pinnedAt
    callback null, team

# Sync team members from third part account
TeamSchema.methods.syncThirdMember = (thirdMember, callback) ->
  team = this

  $invitee = Promise.resolve(thirdMember).then (thirdMember) ->
    throw new Err('PARAMS_MISSING', 'openId') unless thirdMember.openId
    invitation =
      key: "teambition_#{thirdMember.openId}"
      name: thirdMember.name
      role: thirdMember.role

    team.inviteAsync invitation
    # Ignore invitation errors
    .catch (err) -> logger.warn err.stack

  $invitee.nodeify callback

TeamSchema.methods.welcomeNewTeamMember = (_userId, callback) ->
  team = this
  MessageModel = @model 'Message'
  PreferenceModel = @model 'Preference'

  i18n = require '../components/i18n'

  $talkai = serviceLoader.getRobotOf 'talkai'

  $preference = PreferenceModel.findOneAsync _id: _userId, 'language'

  $welcomeMsg = Promise.all [$talkai, $preference]

  .spread (talkai, preference) ->
    $talkai.then (talkai) ->
    welcomeMsg = new MessageModel
      creator: talkai._id
      to: _userId
      team: team._id
      body: i18n.fns(preference?.language or 'zh').welcomeNewTeamMember team
    welcomeMsg.$save()

  .nodeify callback

# ============================== Statics ==============================

TeamSchema.statics.findJoinedRoomIds = (_teamId, _userId, callback) ->
  @findJoinedRoomMembers _teamId, _userId, (err, members = []) ->
    callback err, members.map (member) -> member?._roomId?.toString()

TeamSchema.statics.findJoinedRoomMembers = (_teamId, _userId, callback) ->
  RoomModel = @model 'Room'
  MemberModel = @model 'Member'

  RoomModel.findAsync
    team: _teamId
    isArchived: false
  , '_id'

  .map (room) -> room._id

  .then (_roomIds) ->
    return [] unless _roomIds?.length
    MemberModel.findAsync
      user: _userId
      room: $in: _roomIds
      isQuit: false
    , '_id room prefs'

  .nodeify callback

TeamSchema.statics.findByUserId = (_userId, callback) ->
  MemberModel = @model 'Member'
  MemberModel.find
    user: _userId
    team: $ne: null
    isQuit: false
  .populate 'team'
  .exec (err, members = []) ->
    return callback(err, []) unless members.length
    teams = members.map (member) -> member.team
      .filter (team) -> team?._id
    callback null, teams

TeamSchema.statics.findMemberIds = (_teamId, callback) ->
  MemberModel = @model 'Member'

  MemberModel.findAsync
    team: _teamId
    isQuit: false
  , '_id user'

  .map (member) -> member?._userId?.toString()

  .nodeify callback

TeamSchema.statics.findArchivedRooms = (_teamId, callback = ->) ->
  RoomModel = @model 'Room'
  RoomModel.find
    team: _teamId
    isArchived: true
  .sort _id: 1
  .exec callback

TeamSchema.statics.syncThirdTeam = (thirdTeam, callback) ->
  ensureParams = ['sourceId', 'creator', 'source']
  unless (ensureParams.every (field) -> thirdTeam[field])
    return callback(new Err('PARAMS_MISSING', ensureParams))

  TeamModel = this

  $team = TeamModel.findOneAsync
    sourceId: thirdTeam.sourceId
    source: thirdTeam.source

  .then (team) ->
    team = new TeamModel thirdTeam unless team
    team.name or= thirdTeam.name
    team.sourceName = thirdTeam.name
    team.updatedAt = new Date
    team.$save()

  $team.nodeify callback

TeamSchema.plugin makestatic, methodNames: [
  'addMember'
  'removeMember'
  'joinBySignCode'
  'createJoinMessage'
  'createLeaveMessage'
  'welcomeNewTeamMember'
]
