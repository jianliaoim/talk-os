###
Indexes:
* db.rooms.ensureIndex({team: 1}, {background: true})
* db.rooms.ensureIndex({guestToken: 1}, {unique: true, background: true, sparse: true})
* db.rooms.ensureIndex({email: 1}, {unique: true, background: true, sparse: true})
###

{Schema} = require 'mongoose'
_ = require 'lodash'
Err = require 'err1st'
async = require 'async'
Promise = require 'bluebird'
pinyin = require 'pinyin'
util = require '../util'
makestatic = require './plugins/makestatic'

colors = [
  'purple'
  'indigo'
  'blue'
  'cyan'
  'grass'
  'yellow'
]

_arrRandom = -> util.arrRandom(colors, 1)[0]

_getColor = (val) ->
  return val if val in colors
  return 'blue'

module.exports = RoomSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  topic:
    type: String
    set: (val) ->
      @pinyin = pinyin(val, style: pinyin.STYLE_NORMAL).join('').toLowerCase()
      @pinyins = util.arrHorizon(pinyin(val, heteronym: true, style: pinyin.STYLE_NORMAL)).map (val) -> val.toLowerCase()
      @py = pinyin(val, style: pinyin.STYLE_FIRST_LETTER).join('').toLowerCase()
      @pys = util.arrHorizon(pinyin(val, heteronym: true, style: pinyin.STYLE_FIRST_LETTER)).map (val) -> val.toLowerCase()
      val
  team: type: Schema.Types.ObjectId, ref: 'Team'
  purpose: type: String
  isGeneral: type: Boolean, default: false
  isArchived: type: Boolean, default: false
  isPrivate: type: Boolean, default: false
  color: type: String, default: 'blue', get: _getColor
  email: type: String, lowercase: true
  guestToken: type: String
  isGuestVisible: type: Boolean, default: true
  pinyin: type: String
  pinyins: type: Array
  py: type: String
  pys: type: Array
  memberCount: type: Number, default: 0
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

################## Virtuals ##################

RoomSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

RoomSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

RoomSchema.virtual 'guestUrl'
  .get -> util.buildGuestUrl(@guestToken)

RoomSchema.virtual 'popRate'
  .get -> (@memberCount or 0) * 3

RoomSchema.virtual 'prefs'
  .get -> @_prefs
  .set (@_prefs) -> @_prefs

RoomSchema.virtual 'members'
  .get -> @_members
  .set (@_members) -> @_members

RoomSchema.virtual 'latestMessages'
  .get -> @_latestMessages
  .set (@_latestMessages) -> @_latestMessages

RoomSchema.virtual 'unread'
  .get -> @_unread
  .set (@_unread) -> @_unread

RoomSchema.virtual '_latestReadMessageId'
  .get -> @__latestReadMessageId
  .set (@__latestReadMessageId) -> @__latestReadMessageId

RoomSchema.virtual 'joinDate'
  .get -> @_joinDate
  .set (@_joinDate) -> @_joinDate

RoomSchema.virtual 'isQuit'
  .get -> @_isQuit
  .set (@_isQuit) -> @_isQuit

RoomSchema.virtual 'pinnedAt'
  .get -> @_pinnedAt
  .set (@_pinnedAt) -> @_pinnedAt

RoomSchema.virtual 'isPinned'
  .get -> @_isPinned
  .set (@_isPinned) -> @_isPinned

RoomSchema.virtual '_memberIds'
  .get -> @__memberIds
  .set (@__memberIds) -> @__memberIds

################## Methods ##################
#
###*
 * Add member or guest to the room
 * @param {ObjectId} _userId
 * @return {Model} room - Room model
###
RoomSchema.methods.addMember = (_userId, callback = ->) ->
  MemberModel = @model 'Member'
  UserModel = @model 'User'
  room = this

  if _userId instanceof UserModel
    $user = Promise.resolve _userId
  else
    $user = UserModel.findOneAsync _id: _userId
    .then (user) ->
      throw new Err('OBJECT_MISSING', "user #{_userId}") unless user
      user

  $user = $user.then (user) ->
    conditions =
      room: room._id
      user: _userId
    update = {}
    update.role = 'owner' if "#{_userId}" is "#{room._creatorId}"

    MemberModel.joinAsync conditions, update

    .then (member) ->
      user.role = member.role
      user.prefs = member.prefs
      user.room = room
      user._teamId = room._teamId
      return user

  $setMemberCount = $user.then -> room.setMemberCountAsync()

  Promise.all [$user, $setMemberCount]
  .spread (user) -> user
  .nodeify callback

RoomSchema.methods.setMemberCount = (callback) ->
  MemberModel = @model 'Member'
  room = this
  MemberModel.count room: room._id, isQuit: false
  , (err, num) ->
    room.memberCount = num
    room.save (err, room) ->
      callback null, room

###*
 * Add member to the room
 * This function will check for the team member
 * And add this user to the team if he is not in the team
 * @param {ObjectId|Model} _userId - _userId or user model
 * @return {Model} user - User model
###
RoomSchema.methods.addTeamMember = (_userId, callback = ->) ->
  MemberModel = @model 'Member'
  TeamModel = @model 'Team'
  UserModel = @model 'User'
  room = this

  if _userId instanceof UserModel
    $user = Promise.resolve _userId
  else
    $user = UserModel.findOneAsync _id: _userId
    .then (user) ->
      throw new Err('OBJECT_MISSING', "user #{_userId}") unless user
      user

  if room.isGeneral
    # Add user to general room is equal to add team member
    $addMember = $user.then (user) -> TeamModel.addMemberAsync room._teamId, user
  else
    # First check for the team member and invite the user if not a member of team
    $addTeamMember = $user.then (user) ->
      MemberModel.findOneAsync
        team: room._teamId
        user: user._id
        isQuit: false
      .then (member) ->
        return if member  # Do nothing when team member exists
        TeamModel.addMemberAsync room._teamId, user

    # Then add member to this room
    $addRoomMember = $user.then (user) -> room.addMemberAsync user

    $addMember = Promise.all [$addTeamMember, $addRoomMember]

    .spread (teamMember, roomMember) -> roomMember

  $addMember.then (user) ->
    user.role or= 'member'
    user.room or= room
    user._teamId = room._teamId
    user

  .nodeify callback

###*
 * Invite user by email or mobile
 * Create an invitation if user is nonexistent
 * @param  {Object} conditions {email: email, mobile: mobile}
 * @return {Model} invitee|invitation - User model or invitation model
###
RoomSchema.methods.invite = (conditions, callback = ->) ->
  UserModel = @model 'User'
  InvitationModel = @model 'Invitation'
  room = this
  {email, mobile, key} = conditions
  return callback(new Err('PARAMS_MISSING', 'email, mobile')) unless email or mobile or key
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
    if invitee
      room.addTeamMemberAsync invitee
    else
      conditions.team = room._teamId
      conditions.room = room._id
      InvitationModel.inviteAsync conditions

  .then (invitee) ->
    invitee.room = room
    invitee.role or= 'member'
    invitee._teamId = room._teamId
    invitee

  .nodeify callback

RoomSchema.methods.removeMember = (_userId, callback = ->) ->
  MemberModel = @model 'Member'
  room = this

  MemberModel.update
    room: room._id
    user: _userId
  ,
    isQuit: true
    quitAt: new Date
    updatedAt: new Date
  ,
    multi: true
  , (err) ->
    return callback(err) if err
    room.setMemberCount callback

RoomSchema.methods.archive = (callback = ->) ->
  @isArchived = true
  @save (err, room) ->
    callback err, room
    return if err
    room.emit 'archive', room

RoomSchema.methods.unarchive = (callback = ->) ->
  @isArchived = false
  @save (err, room) -> callback err, room

RoomSchema.methods.updatePrefs = (_userId, prefs, callback) ->
  MemberModel = @model 'Member'
  room = this

  MemberModel.findOneAsync
    room: room._id
    user: _userId
    isQuit: false

  .then (member) ->
    throw new Err('MEMBER_CHECK_FAIL', "room #{room.topic}") unless member

    member.prefs or= {}
    Object.keys(prefs).forEach (key) ->
      member.prefs[key] = prefs[key]

    new Promise (resolve, reject) ->
      member.save (err, member) ->
        return reject(err) if err
        resolve member

  .then (member) ->
    room.prefs = member.prefs
    room

  .nodeify callback

RoomSchema.methods.attachMembers = (callback) ->
  MemberModel = @model 'Member'
  room = this

  MemberModel.find room: room._id, isQuit: false
  .populate 'user'
  .execAsync()

  .then (members = []) ->
    room.members = members.map (member) ->
      _user = member.user
      _user?.prefs = member.prefs
      _user
    .filter (user) -> user

    room._memberIds = room.members.map (user) -> user._id

    room.memberCount = room.members.length
    room

  .nodeify callback

RoomSchema.methods.attachMemberIds = (callback) ->
  MemberModel = @model 'Member'
  room = this
  MemberModel.find
    room: room._id
    isQuit: false
  , 'user'
  , (err, members) ->
    room._memberIds = members?.map (member) -> member._userId
    room.memberCount = room._memberIds.length
    callback err, room

RoomSchema.methods.attachPrefs = (_userId, callback) ->
  room = this

  _attachPrefsFromMember = ->
    MemberModel = room.model 'Member'
    MemberModel.findOneAsync
      user: _userId
      room: room._id
      isQuit: false
    .then (member) ->
      throw new Err('MEMBER_CHECK_FAIL', "room #{room.topic}") unless member
      room.prefs = member.prefs
      room

  Promise.resolve()
  .then ->
    if room.members?
      room.members.forEach (user) ->
        if "#{_userId}" is "#{user._id}"
          room.prefs = user.prefs
      $room = room
    else
      $room = _attachPrefsFromMember()
    $room

  .nodeify callback

RoomSchema.methods.createJoinMessage = (_creatorId, callback = ->) ->
  MessageModel = @model 'Message'
  message = new MessageModel
    _creatorId: _creatorId
    _teamId: @_teamId
    _roomId: @_id
    body: '{{__info-join-room}}'
    isSystem: true
    icon: 'join-room'
  message.save (err, message) -> callback err, message

RoomSchema.methods.createLeaveMessage = (_creatorId, callback = ->) ->
  MessageModel = @model 'Message'
  message = new MessageModel
    _creatorId: _creatorId
    _teamId: @_teamId
    _roomId: @_id
    body: '{{__info-leave-room}}'
    isSystem: true
    icon: 'leave-room'
  message.save (err, message) -> callback err, message

######################################## STATICS ########################################
#
RoomSchema.statics.filterPrivateRooms = (rooms, _userId, callback) ->
  MemberModel = @model 'Member'
  _rooms = []

  _privateRoomIds = rooms.filter (room) ->
    room.isPrivate
  .map (room) -> room._id

  Promise.resolve().then ->
    MemberModel.findAsync
      room: $in: _privateRoomIds
      user: _userId
      isQuit: false
    , '_id room'

  .then (members = []) ->
    _memberRoomIds = members.map (member) -> "#{member.room}"
    _rooms = rooms.filter (room) ->
      return true unless room.isPrivate
      return true if "#{room._id}" in _memberRoomIds
      false
    _rooms

  .nodeify callback

###*
 * Add isQuit, prefs property on each room object
 * @param  {Array} rooms - Room model array
 * @param  {ObjectId} _userId - User id
 * @param  {Function} callback
###
RoomSchema.statics.attachMemberPrefs = (rooms, _userId, callback) ->
  MemberModel = @model 'Member'
  _roomIds = rooms.map (room) -> "#{room._id}"

  MemberModel.findAsync
    room: $in: _roomIds
    user: _userId
  , '_id isQuit room prefs'

  .then (members = []) ->
    memberHash = {}
    members.forEach (member) ->
      memberHash["#{member._roomId}"] = member
    rooms.forEach (room) ->
      member = memberHash["#{room._id}"] or
        prefs: {}
        isQuit: true
      room.prefs = member.prefs
      room.isQuit = member.isQuit
    rooms

  .nodeify callback

###*
 * Read room list that user joined
 * @param  {ObjectId} _userId
 * @param  {Function} callback
 * @return {Promise}
###
RoomSchema.statics.findByUserId = (_userId, callback) ->
  MemberModel = @model 'Member'

  Promise.resolve()

  .then ->
    MemberModel.find
      user: _userId
      room: $ne: null
      isQuit: false
    .populate 'room'
    .exec()

  .map (member) -> member.room

  .filter (room) -> room?._id and not room.isArchived

  .nodeify callback

RoomSchema.statics.findIdsByUserId = (_userId, callback) ->
  RoomModel = this

  RoomModel.findByUserId _userId

  .map (room) -> room?._id?.toString()

  .nodeify callback

RoomSchema.plugin makestatic, methodNames: [
  'addMember'
  'removeMember'
  'addTeamMember'
  'createJoinMessage'
  'createLeaveMessage'
]
