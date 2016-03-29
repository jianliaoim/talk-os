_ = require 'lodash'
async = require 'async'
Err = require 'err1st'
limbo = require 'limbo'
Promise = require 'bluebird'
logger = require 'graceful-logger'

{inviteMailer, rmMailer} = require '../mailers'
util = require '../util'
app = require '../server'

{
  MessageModel
  RoomModel
  PreferenceModel
  MemberModel
  UserModel
  NotificationModel
  ActivityModel
} = limbo.use 'talk'

module.exports = roomController = app.controller 'room', ->

  @mixin require './mixins/permission'

  @ensure '_teamId topic', only: 'create'
  @ensure 'isArchived', only: 'archive'
  @ensure 'isGuestEnabled', only: 'guest'
  @ensure '_userId', only: 'removeMember'

  editActions = 'archive remove removeMember'

  @before 'readableRoom', except: "create update #{editActions}"
  @before 'editableRoom', only: editActions
  @before 'beforeUpdateRoom', only: 'update'
  @before 'accessibleRoom', only: 'create'

  @after 'attachRoomDetail', only: 'join readOne create'
  @after 'attachRoomPrefs', only: 'join readOne create archive'
  @after 'afterArchive', only: 'archive'
  @after 'afterInvite', only: 'invite'
  @after 'afterCreate', only: 'create', parallel: true
  @after 'createActivityAfterCreate', only: 'create', parallel: true
  @after 'updateActivitiesAfterUpdate', only: 'update', parallel: true
  @after 'removeActivitiesAfterRemove', only: 'remove', parallel: true
  @after 'afterJoin', only: 'join', parallel: true
  @after 'afterLeave', only: 'leave', parallel: true
  @after 'afterGuest', only: 'guest', parallel: true

  editableFields = [
    'topic'
    'purpose'
    'color'
    'isPrivate'
    'isGuestVisible'
    'addMembers'
    'removeMembers'
  ]

  @action 'readOne', (req, res, callback) -> callback null, req.get('room')

  @action 'create', (req, res, callback) ->
    {_sessionUserId, topic, _teamId, purpose, color, isPrivate, _memberIds} = req.get()

    room = new RoomModel
      topic: topic
      creator: _sessionUserId
      team: _teamId
      purpose: purpose
      color: color
      isPrivate: isPrivate

    $room = room.$save()

    if _memberIds?.length
      $users = UserModel.findAsync _id: $in: _memberIds
      $addMembers = $users.map (user) ->
        return if "#{user._id}" is "#{room._creatorId}"
        room.addMemberAsync(user).catch ->

    else $addMembers = Promise.resolve()

    Promise.all [$room, $addMembers]

    .spread (room) -> room

    .nodeify callback

  @action 'afterCreate', (req, res, room) ->
    res.broadcast "team:#{room._teamId}", "room:create", room unless room.isPrivate

  @action 'update', (req, res, callback) ->
    {_id, _sessionUserId, topic, purpose, room} = req.get()
    self = this

    update = _.pick req.get(), editableFields

    return callback(new Err 'PARAMS_MISSING', editableFields) if _.isEmpty(update)

    # Update members
    $room = Promise.resolve(room)

    if update.addMembers?.length

      $room = $room.then (room) ->

        Promise.map update.addMembers, (_userId) ->
          room.addMemberAsync _userId

      .then -> room

    if update.removeMembers?.length

      $room = $room.then ->

        Promise.map update.removeMembers, (_userId) ->
          room.removeMemberAsync _userId

      .then -> room

    if update.addMembers or update.removeMembers

      $memberMessage = Promise.resolve().then ->
        message = new MessageModel
          creator: _sessionUserId
          team: room._teamId
          room: room._id
          isSystem: true
          icon: 'join-room'

      if update.addMembers
        $memberMessage = Promise.all [$memberMessage, $room]

        .spread (memberMessage, room) ->

          $memberNames = UserModel.findAsync _id: $in: update.addMembers, 'name'
          .map (user) -> "#{user.name}"
          .then (userNames) -> userNames.join ', '

          $memberNames.then (memberNames) ->
            messageBody = "{{__info-invite-members}} #{memberNames}"
            memberMessage.body = if memberMessage.body then "#{memberMessage.body}, #{messageBody}" else messageBody
            memberMessage

      if update.removeMembers

        $memberMessage = Promise.all [$memberMessage, $room]

        .spread (memberMessage, room) ->

          $memberNames = UserModel.findAsync _id: $in: update.removeMembers, 'name'
          .map (user) -> "#{user.name}"
          .then (userNames) -> userNames.join ', '

          $memberNames.then (memberNames) ->
            messageBody = "{{__info-remove-members}} #{memberNames}"
            memberMessage.icon = 'leave-room'
            memberMessage.body = if memberMessage.body then "#{memberMessage.body}, #{messageBody}" else messageBody
            memberMessage

        $removeMemberNotifications = Promise.resolve(update.removeMembers).map (_userId) ->
          NotificationModel.updateByOptionsAsync
            target: room._id
            type: 'room'
            user: _userId
            team: room._teamId
          , isHidden: true
        .catch (err) -> logger.warn err.stack

      $memberMessage.then (message) -> message.$save()
      .catch (err) -> logger.warn err.stack

    # Update other fields
    fieldUpdates = _.omit update, 'addMembers', 'removeMembers'

    unless _.isEmpty fieldUpdates
      $room = $room.then (room) ->
        for key, val of fieldUpdates
          room[key] = val
        room.$save()

      $updateMessage = $room.then (room) ->
        return unless req.get('topic') or req.get('purpose')

        # Broadcast messages
        message = new MessageModel
          _creatorId: _sessionUserId
          _roomId: _id
          _teamId: room._teamId
          isSystem: true
          icon: 'update-room'

        if topic?  # Update topic
          message.body = "{{__info-update-topic}} #{topic}#{if purpose then ' - ' + purpose else ''}"
        else if purpose?
          message.body = "{{__info-update-purpose}} #{purpose}"

        message.save()

    $room.then (room) -> room.attachMembersAsync()

    .then (room) ->
      res.broadcast "team:#{room._teamId}", "room:update", room
      room

    .nodeify callback

  @action 'join', (req, res, callback) ->
    {_id, _sessionUserId, room} = req.get()

    $member = MemberModel.findOneAsync
      room: _id
      user: _sessionUserId
      isQuit: false

    $join = $member.then (member) ->
      return room if member
      room.addMemberAsync _sessionUserId
      .then ->
        req.newJoined = true
        room

    $join.nodeify callback

  @action 'attachRoomDetail', (req, res, room, callback) ->
    {_sessionUserId} = req.get()
    async.auto
      populateTeam: (callback) -> room.populate 'team', callback
      attachMembers: (callback) -> room.attachMembers callback
      attachLatestMessages: (callback) ->
        MessageModel.findMessagesFromRoom room._id, limit: 30, (err, messages = []) ->
          room.latestMessages = messages
          callback err, room
      attachNotification: (callback) ->
        NotificationModel.findOne
          user: _sessionUserId
          type: 'room'
          target: room._id
          team: room._teamId
        , '_latestReadMessageId unreadNum'
        , (err, notification) ->
          room._latestReadMessageId = notification?._latestReadMessageId
          room.unread = notification?.unreadNum or 0
          callback err, room
    , (err) -> callback err, room

  @action 'attachRoomPrefs', (req, res, room, callback) ->
    {_sessionUserId} = req.get()
    room.attachPrefs _sessionUserId, callback

  # Broadcast new member info after join action
  @action 'afterJoin', (req, res, room) ->
    {_id, _sessionUserId} = req.get()
    PreferenceModel.updateByUserId _sessionUserId, _latestRoomId: room._id
    if req.newJoined  # Broadcast new member
      me = null
      room.members.some (user) ->
        if "#{user._id}" is _sessionUserId
          me = user
          me._roomId = room._id
          me._teamId = room._teamId
          me.room = room.toJSON virtuals: false
          me.room.team = room.team
          return true
        return false
      res.broadcast "team:#{room._teamId}", "room:join", me if me
      room.createJoinMessage _sessionUserId

  @action 'leave', (req, res, callback) ->
    {_sessionUserId, _id, room} = req.get()
    room.removeMember _sessionUserId, callback

  @action 'remove', (req, res, callback) ->
    {_sessionUserId, _id, room} = req.get()
    room.remove (err, room) ->
      callback err, room
      return if err
      res.broadcast "team:#{room._teamId}", "room:remove", room

  @action 'removeMember', (req, res, callback) ->
    {room, _userId} = req.get()
    room.removeMember _userId, (err, room) ->
      callback err, room
      return if err
      data =
        _teamId: room._teamId
        _roomId: room._id
        _userId: _userId
      res.broadcast "team:#{room._teamId}", "room:leave", data

      NotificationModel.updateByOptions
        user: _userId
        target: room._id
        type: 'room'
        team: room._teamId
      , isHidden: true

      room.createLeaveMessage _userId

  @action 'afterLeave', (req, res, ok) ->
    {_sessionUserId, _id, room} = req.get()
    PreferenceModel.updateByUserId _sessionUserId, _latestRoomId: null

    # Remove notification and cancel mails
    NotificationModel.updateByOptions
      user: _sessionUserId
      target: room._id
      type: 'room'
      team: room._teamId
    , isHidden: true

    rmMailer.cancel _sessionUserId, _id, room._teamId

    # Broadcast messages
    data = _roomId: _id, _userId: _sessionUserId, _teamId: room._teamId
    res.broadcast "team:#{room._teamId}", "room:leave", data

    room.createLeaveMessage _sessionUserId

  @action 'invite', (req, res, callback) ->
    {room, _userId, _sessionUserId} = req.get()
    if _userId
      $invitee = UserModel.findOneAsync _id: _userId
      .then (user) ->
        throw new Err('OBJECT_MISSING', "user #{_userId}") unless user
        room.addTeamMemberAsync user
        .then (member) -> user
    else
      conditions = _.pick(req.get(), 'email', 'mobile')
      $invitee = room.inviteAsync conditions

    $invitee.nodeify callback

  @action 'batchInvite', (req, res, callback) ->
    {_id, _sessionUserId, emails, mobiles, _userIds, room} = req.get()
    self = this
    if emails?.length > 200 and mobiles?.length > 200 or _userIds?.length > 200
      return callback(new Err('TOO_MANY_FIELDS'))

    # Invite by _userIds
    if toString.call(_userIds) is '[object Array]'
      _userIds = _.uniq _userIds
      $userInvitees = Promise.resolve(_userIds).map (_userId) ->
        UserModel.findOneAsync _id: _userId
        .then (user) ->
          throw new Err('OBJECT_MISSING', "user #{_userId}") unless user
          room.addTeamMemberAsync user._id
          .then (member) -> user
    else $userInvitees = Promise.resolve []

    # Invite by emails
    if toString.call(emails) is '[object Array]'
      emails = _.uniq emails
      $emailInvitees = Promise.resolve(emails).map (email) ->
        conditions = email: email
        room.inviteAsync conditions
    else $emailInvitees = Promise.resolve []

    # Invite by mobiles
    if toString.call(mobiles) is '[object Array]'
      mobiles = _.uniq mobiles
      $mobileInvitees = Promise.resolve(mobiles).map (mobile) ->
        conditions = mobile: mobile
        room.inviteAsync conditions
    else $mobileInvitees = Promise.resolve []

    # Collect invitees and send messages
    afterInviteAsync = Promise.promisify self.afterInvite

    Promise.all [$userInvitees, $emailInvitees, $mobileInvitees]

    .spread (userInvitees, emailInvitees, mobileInvitees) ->
      invitees = [].concat userInvitees, emailInvitees, mobileInvitees

    .map (invitee) -> afterInviteAsync.call self, req, res, invitee

    .nodeify callback

  @action 'archive', (req, res, callback) ->
    {_sessionUserId, room, isArchived, _id} = req.get()
    method = if isArchived then 'archive' else 'unarchive'
    room[method] callback

  @action 'afterArchive', (req, res, room, callback) ->
    {_sessionUserId} = req.get()
    MemberModel.findOne
      room: room._id
      user: _sessionUserId
    , (err, member) ->
      room.isQuit = if member? then member.isQuit else true
      callback err, room
      res.broadcast "team:#{room._teamId}", "room:archive", room

  ###*
   * Enable guest mode or refresh guest url
  ###
  @action 'guest', (req, res, callback) ->
    {_sessionUserId, isGuestEnabled, room} = req.get()
    if isGuestEnabled
      room.guestToken = util.refreshGuestToken()
    else
      room.guestToken = undefined
    room.save (err, room) ->
      callback err, room
      res.broadcast "team:#{room._teamId}", "room:update", room

  # Remove guest members from room
  @action 'afterGuest', (req, res, room) ->
    {_sessionUserId} = req.get()

    message = new MessageModel
      _creatorId: _sessionUserId
      _teamId: room._teamId
      _roomId: room._id
      isSystem: true
      body: if room.guestToken then '{{__info-enable-guest}}' else '{{__info-disable-guest}}'
      icon: if room.guestToken then 'enable-guest' else 'disable-guest'

    message.save()

    # Do not continue if the guestmode is enabled
    return if room.guestToken
    # Remove guest member from room
    MemberModel.find
      room: room._id
      isQuit: false
    .populate 'user'
    .exec (err, members = []) ->
      return unless members?.length
      users = members.map (member) -> member.user
        .filter (user) -> user?.isGuest
      users or= []
      users.forEach (user) ->
        room.removeMember user._id, (err) ->
          return if err
          data = _roomId: room._id, _userId: user._id
          res.publish "team:#{room._teamId}", "room:leave", data
          room.createLeaveMessage user._id

  ###*
   * Create system message and broadcast events to clients
   * @param  {Model} invitee - User model or invitation model
  ###
  @action 'afterInvite', (req, res, invitee, callback) ->
    {_sessionUserId, room} = req.get()
    if invitee.isInvite  # An invitation model
      res.broadcast "team:#{room._teamId}", "invitation:create", invitee
    else  # A user model
      res.broadcast "team:#{room._teamId}", "room:join", invitee
      res.broadcast "user:#{invitee._id}", "room:join", invitee unless invitee.wasTeamMember
      room.createJoinMessage invitee._id
    inviteMailer.send _sessionUserId, invitee
    callback null, invitee

  ###*
   * Create activity after create room
  ###
  @action 'createActivityAfterCreate', (req, res, room) ->

    activity = new ActivityModel
      team: room._teamId
      target: room._id
      type: 'room'
      creator: room._creatorId
      text: "{{__info-create-room}}"
    if room.isPrivate
      activity.isPublic = false
      activity.members = room._memberIds
    else
      activity.isPublic = true

    activity.$save().catch (err) -> logger.warn err.stack

  ###*
   * Update activities when update room topic or room's visible state
  ###
  @action 'updateActivitiesAfterUpdate', (req, res, room) ->
    return unless (['topic', 'isPrivate'].some (key) -> req.get(key)?)

    $activities = ActivityModel.findAsync target: room._id

    # Should read new room members when set room to private
    if req.get('isPrivate') and room.isPrivate
      $room = room.attachMemberIdsAsync()
    else
      $room = Promise.resolve(room)

    $activities.map (activity) ->

      activity.text = "{{__info-create-room}} #{room.topic}"

      switch
        when activity.isPublic and room.isPrivate
          activity.isPublic = false
          activity.members = room._memberIds
        when (not activity.isPublic) and (not room.isPrivate)
          activity.isPublic = true
          activity.members = []

      activity.$save()

    .catch (err) -> logger.warn err.stack

  @action 'removeActivitiesAfterRemove', (req, res, room) ->
    return unless room?._id and room?._teamId
    $activities = ActivityModel.removeAsync
      target: room._id
    .catch (err) -> logger.warn err.stack
