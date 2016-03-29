async = require 'async'
_ = require 'lodash'
Promise = require 'bluebird'
Err = require 'err1st'
limbo = require 'limbo'
Err = require 'err1st'
request = require 'request'
util = require '../../util'

{
  RoomModel
  TeamModel
  MessageModel
  MemberModel
  UserModel
  TagModel
  FavoriteModel
  StoryModel
  DeviceTokenModel
  IntegrationModel
  NotificationModel
  InvitationModel
  MarkModel
  GroupModel
  ActivityModel
} = limbo.use 'talk'

RIGHT_READ: 0b0001
RIGHT_EDIT: 0b0010

###*
 * Permission
 * team
 * |
 * room - user
 * |
 * integration
###

# readable: readOne
# editable: update/remove
# accessible: create/read[list]
#
############################# Privates #############################
_accessToRoomMessage = (req, res, callback) ->
  {_sessionUserId, _roomId, _toId, _id, _teamId} = req.get()
  async.waterfall [
    (next) ->
      MemberModel.findOne
        room: _roomId
        user: _sessionUserId
        isQuit: false
      .populate 'room'
      .exec next
    (member, next) ->
      return next(new Err('MEMBER_CHECK_FAIL', 'room')) unless member?.room
      return next(new Err('ROOM_IS_ARCHIVED')) if member.room.isArchived
      {_teamId} = member.room
      req.set '_teamId', _teamId
      next()
  ], callback

_accessToDirectMessage = (req, res, callback) ->
  {_sessionUserId, _roomId, _toId, _id, _teamId} = req.get()
  async.waterfall [
    (next) ->
      MemberModel.find
        user: $in: [_sessionUserId, _toId]
        team: _teamId
        isQuit: false
      , 'user'
      , next
    (members, next) ->
      _userIds = members.map (member) -> "#{member.user}"
      exist = [_sessionUserId, _toId].every (_userId) -> _userId in _userIds
      return next(new Err('MEMBER_CHECK_FAIL', 'team')) unless exist
      next()
  ], callback

# Send message to a story
_accessToStoryMessage = (req, res, callback) ->
  {_sessionUserId, _storyId, _teamId, story} = req.get()

  # Check if the story is existing
  if story
    $story = Promise.resolve(story)
  else
    $story = StoryModel.findOneAsync _id: _storyId
    .then (story) ->
      throw new Err('OBJECT_MISSING', "story #{_storyId}") unless story
      req.set 'story', story
      req.set '_teamId', story._teamId
      return story

  $isMember = $story.then (story) ->
    return true if "#{story._creatorId}" is _sessionUserId
    hasMember = story._memberIds.some (_memberId) -> "#{_memberId}" is _sessionUserId
    return true if hasMember
    throw new Err('NO_PERMISSION')

  $isMember.nodeify callback

module.exports = permission =

  isTeamMember: (req, res, callback) ->
    {_sessionUserId, _teamId} = req.get()
    return callback(new Err('PARAMS_MISSING', '_teamId')) unless _teamId
    MemberModel.findOne
      user: _sessionUserId
      team: _teamId
      isQuit: false
    , (err, member) ->
      return callback(new Err('MEMBER_CHECK_FAIL', 'team')) unless member
      req.set 'member', member
      callback()

  isTeamAdmin: (req, res, callback) ->
    {_sessionUserId, _teamId} = req.get()
    return callback(new Err('PARAMS_MISSING', '_teamId')) unless _teamId
    MemberModel.findOne
      user: _sessionUserId
      team: _teamId
      isQuit: false
    , (err, member) ->
      return callback(new Err('MEMBER_CHECK_FAIL', 'team')) unless member
      return callback(new Err('NO_PERMISSION')) unless member.role in ['owner', 'admin']
      req.set 'member', member
      callback()

  isRoomMember: (req, res, callback) ->
    {_sessionUserId, _roomId} = req.get()
    return callback(new Err('PARAMS_MISSING', '_roomId')) unless _roomId

    self = this

    $room = RoomModel.findOneAsync _id: _roomId

    .then (room) ->
      throw new Err('OBJECT_MISSING', "room #{_roomId}") unless room
      req.set 'room', room
      req.set '_teamId', room._teamId
      room

    $room.then (room) ->
      if room.isPrivate  # Check room member
        MemberModel.findOneAsync
          user: _sessionUserId
          room: _roomId
          isQuit: false
        .then (member) ->
          throw new Err('MEMBER_CHECK_FAIL', "room #{_roomId}") unless member
          callback()
      else  # Check team member
        self.isTeamMember req, res, callback

    .catch callback

  isStoryMember: (req, res, callback) ->
    {_storyId, _sessionUserId} = req.get()
    return callback(new Err('PARAMS_MISSING', '_storyId')) unless _storyId
    StoryModel.findOne _id: _storyId, (err, story) ->
      return callback(new Err('OBJECT_MISSING', "story #{_storyId}")) unless story
      hasMember = story._memberIds.some (_memberId) -> "#{_memberId}" is _sessionUserId
      return callback(new Err('NO_PERMISSION')) unless hasMember
      req.set '_teamId', story._teamId
      req.set 'story', story
      callback()

  ###*
   * Ensure user is member of the team
  ###
  readableTeam: (req, res, callback = ->) ->
    {_sessionUserId, _id} = req.get()
    self = this
    _teamId = _id
    req.set '_teamId', _teamId
    self.isTeamMember req, res, (err) ->
      return callback(err) if err
      TeamModel.findOne _id: _teamId, (err, team) ->
        return callback(new Err('OBJECT_MISSING', "team #{_teamId}")) unless team
        req.set 'team', team
        callback()

  editableTeam: (req, res, callback = ->) ->
    {_sessionUserId, _id, prefs, color, name} = req.get()
    self = this
    _teamId = _id
    req.set '_teamId', _teamId

    TeamModel.findOne _id: _teamId, (err, team) ->
      return callback(new Err('OBJECT_MISSING', "team #{_teamId}")) unless team
      req.set 'team', team
      # Update team color and name should have admin permission
      if (['color', 'name'].some (key) -> req.get(key)?)
        return self.isTeamAdmin req, res, callback
      else
        return self.isTeamMember req, res, callback

  ###*
   * A edit B one's profile
   * A should have higher permission than B
   * owner > admin > member
  ###
  checkRole: (req, res, callback) ->
    {_teamId, _userId, _sessionUserId} = req.get()
    _teamId or= req.get('_id')

    return callback(new Err('PARAMS_MISSING', '_teamId')) unless _teamId

    rolePerm =
      'owner': 2
      'admin': 1
      'member': 0

    MemberModel.find
      team: _teamId
      user: $in: [_userId, _sessionUserId]
      isQuit: false
    , (err, members) ->
      roleA = 0
      roleB = 0
      members.forEach (member) ->
        if "#{member._userId}" is _sessionUserId
          roleA = rolePerm[member.role] or 0
        if "#{member._userId}" is _userId
          roleB = rolePerm[member.role] or 0
      if roleA > roleB
        callback()
      else
        callback(new Err('NO_PERMISSION'))

  # readOne
  readableIntegration: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    async.waterfall [
      (next) ->
        IntegrationModel.findOne
          _id: _id
        , next
      (integration, next) ->
        return next(new Err('OBJECT_MISSING', "integration #{_id}")) unless integration
        {_teamId} = integration
        req.set 'integration', integration
        MemberModel.findOne
          user: _sessionUserId
          team: _teamId
          isQuit: false
        , next
      (member, next) ->
        return next(new Err('MEMBER_CHECK_FAIL', 'team')) unless member
        next()
    ], callback

  # update/remove
  editableIntegration: (req, res, callback = ->) ->
    {_id, _sessionUserId} = req.get()
    async.waterfall [
      (next) ->
        IntegrationModel.findOne
          _id: _id
        , next
      (integration, next) ->
        req.set 'integration', integration
        return next(new Err('OBJECT_MISSING', "integration #{_id}")) unless integration
        return next() if _sessionUserId is "#{integration._creatorId}"
        {_teamId} = integration
        MemberModel.findOne
          team: _teamId
          user: _sessionUserId
          isQuit: false
        , (err, member) ->
          return next(new Err('NO_PERMISSION')) unless member?.role in ['owner', 'admin']
          next()
    ], callback

  # read/create
  accessibleIntegration: (req, res, callback = ->) ->
    {_teamId, _sessionUserId} = req.get()
    MemberModel.findOne
      team: _teamId
      user: _sessionUserId
      isQuit: false
    , (err, member) ->
      return callback(new Err('MEMBER_CHECK_FAIL', 'team')) unless member
      req.set 'member', member
      callback()

  # Privilege to readOne room
  readableRoom: (req, res, callback = ->) ->
    req.set '_roomId', req.get('_id')
    @isRoomMember req, res, callback

  # Privilege to create/join room
  accessibleRoom: (req, res, callback = ->) ->
    {_sessionUserId, _roomId, _id, guestToken} = req.get()
    _roomId or= _id

    async.waterfall [
      (next) ->
        if _roomId
          RoomModel.findOne
            _id: _roomId
          , (err, room) ->
            return next(new Err('OBJECT_MISSING', "room #{_roomId}")) unless room?
            req.set '_teamId', room._teamId
            return next() unless room.isPrivate
            MemberModel.findOne
              room: _roomId
              user: _sessionUserId
              isQuit: false
            , (err, member) ->
              return next(new Err('MEMBER_CHECK_FAIL', 'room')) unless member
              next()
        else next()
      (next) ->
        {_teamId} = req.get()
        return next(new Err('NO_PERMISSION')) unless _teamId
        # Ensure user is team member
        MemberModel.findOne
          team: _teamId
          user: _sessionUserId
          isQuit: false
        , (err, member) ->
          return next(new Err('MEMBER_CHECK_FAIL', 'team')) unless member?
          next(err, member)
    ], callback

  # Room admin or team admin
  editableRoom: (req, res, callback) ->
    {_sessionUserId, _id} = req.get()
    self = this

    $room = RoomModel.findOneAsync _id: _id

    .then (room) ->
      throw new Err('OBJECT_MISSING', "room #{_id}") unless room
      req.set 'room', room

      if room.isGeneral
        # General room can not be archived
        if req.get('isArchived')
          throw new Err('INVALID_OPERATION', 'Archive general room')
        # General room can not remove member
        if req.action is 'removeMember' or req.get('removeMembers')
          throw new Err('INVALID_OPERATION', 'Remove member from general room')

      room

    $roomMember = $room.then (room) ->
      MemberModel.findOneAsync
        team: room._teamId
        user: _sessionUserId
        isQuit: false

    Promise.all [$room, $roomMember]

    .spread (room, roomMember) ->
      return if "#{room._creatorId}" is _sessionUserId
      return if roomMember.role in ['owner', 'admin']
      req.set "_teamId", room._teamId
      self.isTeamAdminAsync req, res

    .nodeify callback

  beforeUpdateRoom: (req, res, callback) ->
    {_sessionUserId, _id} = req.get()

    adminFields = ['topic', 'purpose', 'color', 'isPrivate', 'isGuestVisible', 'removeMembers']
    haveAdminFields = adminFields.some (field) -> req.get(field)?

    return @editableRoom req, res, callback if haveAdminFields

    memberFields = ['addMembers']
    haveMemberFields = memberFields.some (field) -> req.get(field)
    return callback(new Err('PARAMS_MISSING', memberFields)) unless haveMemberFields

    $room = RoomModel.findOneAsync _id: _id
    .then (room) ->
      throw new Err('OBJECT_MISSING', "room #{_id}") unless room
      req.set 'room', room
      room

    $roomMember = $room.then (room) ->
      MemberModel.findOneAsync
        user: _sessionUserId
        room: room._id
        isQuit: false

    Promise.all [$room, $roomMember]

    .spread (room, roomMember) ->
      throw new Err('MEMBER_CHECK_FAIL', "Room #{_id}") unless roomMember

    .nodeify callback

  # Send message to room or
  # Send message to a team member
  # User should be a room member when request message.create/clear
  accessibleMessage: (req, res, callback) ->
    return callback() if req.robot  # Do not check for membership when the message is post by robot

    # Use params from user request query or body
    switch
      when req.getParams('_roomId')
        req.remove '_toId', '_storyId'
        req.set '_roomId', req.getParams('_roomId')
        return _accessToRoomMessage req, res, callback
      when req.getParams('_toId') and req.getParams('_teamId')
        req.remove '_roomId', '_storyId'
        req.set '_toId', req.getParams('_toId')
        req.set '_teamId', req.getParams('_teamId')
        return _accessToDirectMessage req, res, callback
      when req.getParams('_storyId')
        req.remove '_roomId', '_toId'
        req.set '_storyId', req.getParams('_storyId')
        return _accessToStoryMessage req, res, callback
      else return callback(new Err('PARAMS_MISSING', '"_roomId", "_storyId", "_toId & _teamId"'))

  readableMessage: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()

    self = this

    MessageModel.findOne _id: _id, (err, message) ->
      return callback(new Err('OBJECT_MISSING', "message #{_id}")) unless message
      req.set 'message', message
      return callback() if _sessionUserId is "#{message._creatorId}"

      switch
        when message._toId
          if _sessionUserId is "#{message._toId}"
            return callback()
          else
            return callback(new Err("NO_PERMISSION"))

        when message._roomId
          req.set '_roomId', message._roomId
          return self.isRoomMember req, res, callback

        when message._storyId
          req.set '_storyId', message._storyId
          return self.isStoryMember req, res, callback

        else return callback(new Err("NO_PERMISSION"))

  readableMessages: (req, res, callback) ->
    {_sessionUserId, _roomId, _toId, _teamId, _storyId} = req.get()
    self = this

    switch
      when _roomId
        req.remove '_toId', '_storyId'
        return self.isRoomMember req, res, callback
      when _toId and _teamId
        req.remove '_roomId', '_storyId'
        return self.isTeamMember req, res, callback
      when _storyId
        req.remove '_toId', '_roomId'
        return self.isStoryMember req, res, callback
      else
        return callback(new Err('PARAMS_MISSING', '_roomId', '_toId', '_teamId', '_storyId'))

  editableMessage: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    MessageModel.findOne
      _id: _id
    , (err, message) ->
      req.set 'message', message
      return callback(new Err('OBJECT_MISSING', 'message')) unless message
      # When only update _tagIds, do not need any user permissions
      needCreatorFields = ['body', 'attachments'].some (key) -> req.get key
      return callback() if req.get('_tagIds') and not needCreatorFields
      return callback(new Err('NO_PERMISSION')) unless "#{message._creatorId}" is _sessionUserId
      callback()

  deletableMessage: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    async.waterfall [
      (next) ->
        MessageModel.findOne
          _id: _id
        , next
      (message, next) ->
        return callback(new Err('OBJECT_MISSING', 'message')) unless message?._teamId
        req.set 'message', message
        return callback() if "#{message._creatorId}" is _sessionUserId
        MemberModel.findOne
          user: _sessionUserId
          team: message._teamId
        , next
      (member, next) ->
        return callback(new Err('NO_PERMISSION')) unless member.role in ['owner', 'admin']
        next()
    ], callback

  editableFile: (req, res, callback = ->) ->
    {_id, _sessionUserId} = req.get()
    async.waterfall [
      (next) ->
        MessageModel.findOne
          'file._id': _id
        , next
      (message, next) ->
        return callback(new Err 'OBJECT_MISSING', "file #{_id}") unless message
        req.set 'message', message
        return callback() if "#{message._creatorId}" is "#{_sessionUserId}"
        MemberModel.findOne
          user: _sessionUserId
          team: message._teamId
          isQuit: false
        , next
      (member, next) ->
        return callback(new Err 'NO_PERMISSION') unless member?.role in ['owner', 'admin']
        next()
    ], callback

  editableDeviceToken: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    DeviceTokenModel.findOne
      _id: _id
    , (err, devicetoken) ->
      return callback(new Err 'NO_PERMISSION') unless "#{devicetoken._userId}" is _sessionUserId
      callback()

  creatableFavorite: (req, res, callback) ->
    {_messageId, _sessionUserId} = req.get()
    self = this
    MessageModel.findOne _id: _messageId, (err, message) ->
      return callback(new Err('OBJECT_MISSING', "message #{_messageId}")) unless message
      req.set '_roomId', message._roomId if message._roomId
      req.set '_storyId', message._storyId if message._storyId
      if message._toId and message._creatorId
        if "#{message._toId}" is _sessionUserId
          req.set '_toId', "#{message._creatorId}"
        else
          req.set '_toId', "#{message._toId}"
      req.set '_teamId', message._teamId
      req.set 'message', message
      self.readableMessages req, res, callback

  editableFavorite: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    FavoriteModel.findOne _id: _id, (err, favorite) ->
      return callback(new Err('OBJECT_MISSING', "favorite #{_id}")) unless favorite
      return callback(new Err('NO_PERMISSION')) unless _sessionUserId is "#{favorite._favoritedById}"
      req.set 'favorite', favorite
      callback()

  editableFavorites: (req, res, callback) ->
    {_favoriteIds, _sessionUserId} = req.get()
    FavoriteModel.find _id: $in: _favoriteIds, (err, favorites) ->
      return callback(new Err("OBJECT_MISSING", 'favorites')) unless favorites?.length
      hasPermission = favorites.every (favorite) -> _sessionUserId is "#{favorite._favoritedById}"
      return callback(new Err("NO_PERMISSION")) unless hasPermission
      req.set 'favorites', favorites
      callback()

  ###*
   * Ensure there is a team id in params
   * Read the team id from room when the param is not given
  ###
  ensureTeamId: (req, res, callback) ->
    {_roomId, _teamId, _storyId} = req.get()
    if _roomId
      RoomModel.findOne
        _id: _roomId
      , (err, room) ->
        return callback(new Err('OBJECT_MISSING', "room #{_roomId}")) unless room?._teamId
        req.set '_teamId', room._teamId
        req.set 'room', room
        callback()
    else if _storyId
      StoryModel.findOne
        _id: _storyId
      , (err, story) ->
        return callback(new Err('OBJECT_MISSING', "story #{_storyId}")) unless story?._teamId
        req.set '_teamId', story._teamId
        req.set 'story', story
        callback()
    else if _teamId
      callback()
    else callback(new Err('PARAMS_MISSING', '_teamId'))

  editableTag: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    self = this
    TagModel.findOne _id: _id, (err, tag) ->
      return callback(new Err('OBJECT_MISSING', "tag #{_id}")) unless tag
      req.set 'tag', tag
      return callback() if _sessionUserId is "#{tag._creatorId}"
      req.set '_teamId', tag._teamId
      return self.isTeamAdmin req, res, callback

  readableStory: (req, res, callback) ->
    req.set '_storyId', req.get('_id')
    return @isStoryMember req, res, callback

  editableStory: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    self = this
    StoryModel.findOne _id: _id, (err, story) ->
      return callback(new Err('OBJECT_MISSING', "story #{_id}")) unless story
      req.set 'story', story
      return callback() if _sessionUserId is "#{story._creatorId}"
      req.set '_teamId', story._teamId
      return self.isTeamAdmin req, res, callback

  ###*
   * Update fields like removeMembers, data should need the user have the admin previlege
   * But other fields like addMembers only need the user have the member previlege
  ###
  beforeUpdateStory: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()

    adminFields = ['removeMembers', 'data']
    haveAdminFields = adminFields.some (field) -> req.get(field)
    return @editableStory req, res, callback if haveAdminFields

    memberFields = ['addMembers']
    haveMemberFields = memberFields.some (field) -> req.get(field)
    return callback(new Err('PARAMS_MISSING', memberFields)) unless haveMemberFields

    StoryModel.findOne _id: _id, (err, story) ->
      return callback(new Err('OBJECT_MISSING', "Story #{_id}")) unless story
      req.set 'story', story
      isMember = story._memberIds.some (_memberId) -> "#{_memberId}" is _sessionUserId
      return callback(new Err('MEMBER_CHECK_FAIL', "Story #{_id}")) unless isMember
      callback()

  creatableNotification: (req, res, callback) ->
    {_targetId, type, _sessionUserId, _teamId} = req.get()
    switch type
      when 'dms'
        return callback(new Err('PARAMS_INVALID', '_targetId')) if _targetId is _sessionUserId
        MemberModel.find
          user: $in: [_targetId, _sessionUserId]
          team: _teamId
          isQuit: false
        , 'user'
        , (err, members) ->
          _userIds = members.map (member) -> "#{member._userId}"
          exist = [_sessionUserId, _targetId].every (_userId) -> _userId in _userIds
          return callback(new Err('MEMBER_CHECK_FAIL', 'team')) unless exist
          callback()
      when 'room'
        req.set '_roomId', _targetId
        return @isRoomMember req, res, callback
      when 'story'
        req.set '_storyId', _targetId
        return @isStoryMember req, res, callback
      else return callback(new Err('PARAMS_INVALID', 'type'))

  editableNotification: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    NotificationModel.findOne _id: _id, (err, notification) ->
      return callback(new Err('OBJECT_MISSING', "notification #{_id}")) unless notification
      req.set 'notification', notification
      return callback(new Err('NO_PERMISSION')) unless "#{notification._userId}" is _sessionUserId
      callback()

  editableInvitation: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    self = this
    InvitationModel.findOne _id: _id, (err, invitation) ->
      return callback(new Err('OBJECT_MISSING', "invitation #{_id}")) unless invitation
      req.set '_teamId', invitation._teamId
      req.set 'invitation', invitation
      return self.isTeamAdmin req, res, callback

  readableMarks: (req, res, callback) ->
    {_targetId} = req.get()
    req.set '_storyId', _targetId
    return @isStoryMember req, res, callback

  deletableMark: (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    self = this
    MarkModel.findOne _id: _id, (err, mark) ->
      return callback(new Err('OBJECT_MISSING', "mark #{_id}")) unless mark
      req.set 'mark', mark
      req.set '_teamId', mark.team
      return callback() if "#{mark._creatorId}" is _sessionUserId
      return self.isTeamAdmin req, res, callback

  editableGroup: (req, res, callback) ->
    {_id} = req.get()
    self = this
    GroupModel.findOne _id: _id, (err, group) ->
      return callback(new Err('OBJECT_MISSING', "group #{_id}")) unless group
      req.set 'group', group
      req.set '_teamId', group._teamId
      return self.isTeamAdmin req, res, callback

  deletableActivity: (req, res, callback) ->
    self = this
    ActivityModel.findOne _id: req.get('_id'), (err, activity) ->
      return callback(new Err('OBJECT_MISSING', "activity #{req.get('_id')}")) unless activity
      req.set 'activity', activity
      req.set '_teamId', activity._teamId
      return callback() if "#{activity._creatorId}" is req.get('_sessionUserId')
      return self.isTeamAdmin req, res, callback

Promise.promisifyAll permission
