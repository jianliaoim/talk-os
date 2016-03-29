_ = require 'lodash'
async = require 'async'
Err = require 'err1st'
jwt = require 'jsonwebtoken'
validator = require 'validator'
limbo = require 'limbo'
Promise = require 'bluebird'
serviceLoader = require 'talk-services'
logger = require 'graceful-logger'

config = require 'config'
syncers = require '../syncers'
inviteMailer = require '../mailers/invite'
util = require '../util'
app = require '../server'
i18n = require '../components/i18n'

{
  TeamModel
  PreferenceModel
  MessageModel
  RoomModel
  MemberModel
  NoticeModel
  UserModel
  InvitationModel
  NotificationModel
  StoryModel
  ActivityModel
} = limbo.use 'talk'

module.exports = teamController = app.controller 'team', ->

  @mixin require './mixins/permission'
  @mixin require './mixins/general'

  @ratelimit '5 10', only: 'sync'

  @ensure 'name', only: 'create'
  @ensure '_userId', only: 'removeMember setMemberRole'
  @ensure 'role', only: 'setMemberRole'
  @ensure 'socketId', only: 'subscribe unsubscribe'
  @ensure '_targetId', only: 'pinTarget unpinTarget'
  @ensure 'prefs', only: 'updatePrefs'
  @ensure 'properties', only: 'properties'
  @ensure 'refer', only: 'sync thirds'
  @ensure 'sourceId refer', only: 'syncOne'
  @ensure 'inviteCode', only: 'joinByInviteCode readByInviteCode'
  @ensure 'signCode', only: 'joinBySignCode'

  @before 'checkRole', only: 'setMemberRole removeMember'
  @before 'setSessionUser', only: 'read sync thirds syncOne joinByInviteCode'
  @before 'checkSignCode', only: 'join'
  @before 'readableTeam', only: 'readOne join subscribe rooms members latestMessages leave invite batchInvite pinTarget unpinTarget'
  @before 'checkTargetType', only: 'pinTarget unpinTarget'
  @before 'editableTeam', only: 'update updatePrefs removeMember setMemberRole refresh'
  @before 'skipTalkai', only: 'removeMember'
  @before 'checkInvitations', only: 'read'
  @before 'checkUnionTeams', only: 'sync'

  @after 'attachTeamsDetail', only: 'read sync'
  @after 'setMemberVisited', only: 'join'
  @after "attachTeamDetail", only: 'create readOne join'
  @after 'afterInvite', only: 'invite'
  @after 'afterJoin', only: 'join', parallel: true
  @after 'checkForNewNotice', only: 'join', parallel: true
  @after 'afterLeave', only: 'leave', parallel: true
  @after 'afterPin', only: 'pinTarget unpinTarget', parallel: true
  @after 'createActivityAfterInvite', only: 'invite', parallel: true
  @after 'filterSensitiveFromTeam', only: 'join readOne'
  @after 'filterSensitiveFromMembers', only: 'members'

  editableFields = [
    'name'
    'description'
    'color'
    'prefs'
    'shortName'
    'logoUrl'
  ]

  @action 'read', (req, res, callback) ->
    {_sessionUserId} = req.get()
    TeamModel.findByUserId _sessionUserId, callback

  # Sync teams from a connected account
  @action 'sync', (req, res, callback) ->
    {_sessionUserId} = req.get()
    TeamModel.findByUserId _sessionUserId, callback

  # Sync one team from a connected account
  @action 'syncOne', (req, res, callback) ->
    {_sessionUserId, sessionUser, sourceId, accountToken, refer} = req.get()
    return callback(new Err('INVALID_TOKEN')) unless sessionUser.accountId
    $unions = util.getAccountUserAsync(accountToken).then (user) -> user.unions

    $union = $unions.filter (union) -> return true if union.refer is refer and union.accessToken

    .then (unions) ->
      throw new Err('INVALID_REFER') unless unions?.length and syncers[refer]
      union = unions[0]

    $syncer = $union.then (union) -> syncer = syncers[union.refer]

    $thirdTeam = Promise.all [$syncer, $union]
    .spread (syncer, union) -> syncer.getTeamAsync sourceId, union

    # Merge third part team to local team
    $team = $thirdTeam.then (thirdTeam) ->
      thirdTeam.source = refer
      thirdTeam.creator = _sessionUserId
      TeamModel.syncThirdTeamAsync thirdTeam

    # Sync members from third part team
    $syncMember = Promise.all [$syncer, $union, $team]

    .spread (syncer, union, team) ->

      return unless toString.call(syncer.getTeamMembersAsync) is '[object Function]'

      $members = syncer.getTeamMembersAsync union, team

      .map (thirdMember) ->

        team.syncThirdMemberAsync thirdMember
        # Log sync errors
        .catch (err) -> logger.warn err.stack

      .filter (invitee) -> invitee

      .map (invitee) ->
        if invitee.isInvite
          res.broadcast "team:#{team._id}", "invitation:create", invitee
        else  # 邀请成员
          res.broadcast "team:#{team._id}", "team:join", invitee
          res.broadcast "user:#{invitee._id}", "team:join", invitee

    # Log invitation errors
    .catch (err) -> logger.warn err.stack

    # Response
    Promise.all [$team, $syncMember]
    .spread (team) -> team
    .nodeify callback

  # Read third-part teams from connected accounts
  @action 'thirds', (req, res, callback) ->
    {_id, sessionUser, accountToken, refer} = req.get()
    return callback(new Err('INVALID_TOKEN')) unless sessionUser.accountId

    $unions = util.getAccountUserAsync(accountToken).then (user) -> user.unions

    $thirdTeams = $unions.filter (union) -> return true if union.refer is refer and union.accessToken

    .then (unions) ->
      throw new Err('INVALID_REFER') unless unions?.length and syncers[refer]
      union = unions[0]
      syncer = syncers[refer]
      syncer.getTeamsAsync union

    $thirdTeams.nodeify callback

  @action 'create', (req, res, callback) ->
    {_sessionUserId, name, color} = req.get()
    team = new TeamModel
      name: name
      creator: _sessionUserId
      color: color
    team.save (err, team) -> callback err, team

  @action 'readOne', (req, res, callback) -> callback null, req.get('team')

  @action 'update', (req, res, callback) ->
    self = this
    {_id, _sessionUserId} = req.get()
    conditions = _id: _id
    update = _.pick req.get(), editableFields
    return callback(new Err 'PARAMS_MISSING', editableFields) if _.isEmpty(update)
    async.waterfall [
      (next) ->
        TeamModel.findOneAndSave conditions, update, (err, team) ->
          return next(new Err 'NAME_CONFLICT') if err and req.get('shortName')
          return next(err) if err or not team
          # Async operations of team update
          # Broadcast team:update messages and sync team
          res.broadcast "team:#{team?._id}", "team:update", _.omit team.toJSON(), 'prefs'
          next err, team
      (team, next) ->
        return self.updatePrefs(req, res, next) if update.prefs
        next null, team
    ], callback

  @action 'updatePrefs', (req, res, callback) ->
    {_sessionUserId, team, prefs} = req.get()
    team.updatePrefs _sessionUserId, prefs, (err, team) ->
      return callback(err) if err
      callback err, team

      {prefs} = team
      prefs = prefs?.toJSON?() if prefs?.toJSON
      prefs._teamId = team._id
      prefs._userId = _sessionUserId

      if prefs.alias?
        res.broadcast "team:#{team._id}", "team.members.prefs:update", prefs

  @action 'join', (req, res, callback) -> TeamModel.findOne _id: req.get('_id'), callback

  # Join client to team channel
  @action 'subscribe', (req, res, callback) ->
    {socketId, _sessionUserId} = req.get()

    return callback(new Err('PARAMS_MISSING', 'socketId')) unless socketId

    PreferenceModel.updateByUserId _sessionUserId, _latestTeamId: req.get('_id')

    res.join "team:#{req.get('_id')}", callback

  # Remove a client from team channel
  @action 'unsubscribe', (req, res, callback) ->
    {socketId} = req.get()

    return callback(new Err('PARAMS_MISSING', 'socketId')) unless socketId

    res.leave "team:#{req.get('_id')}", callback

  @action 'rooms', (req, res, callback) ->
    {_sessionUserId, _id, isArchived, team} = req.get()
    return @archivedRooms req, res, callback if isArchived
    async.waterfall [
      (next) -> team.attachRooms (err, team) -> next err, team?.rooms
      (rooms, next) -> RoomModel.attachMemberPrefs rooms, _sessionUserId, next
      (rooms, next) -> RoomModel.filterPrivateRooms rooms, _sessionUserId, next
      (rooms, next) -> team.attachUnreadNums _sessionUserId, (err, team) -> next err, rooms
      (rooms, next) ->
        async.map rooms, (room, next) ->
          room.attachMemberIds next
        , next
    ], callback

  @action 'archivedRooms', (req, res, callback) ->
    {_id, _sessionUserId} = req.get()
    TeamModel.findArchivedRooms _id, (err, rooms = []) ->
      rooms = rooms.filter (room) ->  "#{room._creatorId}" is "#{_sessionUserId}" or not room.isPrivate
      callback err, rooms

  @action 'members', (req, res, callback) ->
    {_sessionUserId, _id, team, isQuit} = req.get()
    isQuit = if isQuit then true else false

    $members = MemberModel.find
      team: team._id
      isQuit: isQuit
    .populate 'user'
    .execAsync()
    .then (members) ->
      members = members?.map (member) ->
        _user = member.user
        _user?.prefs = member.prefs
        _user?.role = member.role
        _user
      .filter (user) ->
        return if user?.isGuest
        return user

    $team = $members.then (members) ->
      team.members = members
      team.attachUnreadNumsAsync _sessionUserId

    $team.then (team) -> team.members

    .nodeify callback

  @action 'latestMessages', (req, res, callback) ->
    {_sessionUserId, _id} = req.get()
    teamController.call 'readOne', req, res, (err, team) ->
      callback err, team?.latestMessages

  @action 'leave', (req, res, callback) ->
    {_sessionUserId, _id, team} = req.get()
    PreferenceModel.updateByUserId _sessionUserId, _latestTeamId: null
    team.removeMember _sessionUserId, (err) -> callback null, ok: 1

  @action 'invite', (req, res, callback) ->
    {team, _userId, _sessionUserId} = req.get()
    if _userId
      $invitee = UserModel.findOneAsync _id: _userId
      .then (user) ->
        throw new Err('OBJECT_MISSING', "user #{_userId}") unless user
        team.addMemberAsync user
    else
      conditions = _.pick(req.get(), 'email', 'mobile')
      $invitee = team.inviteAsync conditions

    $invitee.nodeify callback

  @action 'batchInvite', (req, res, callback) ->
    {_id, _sessionUserId, emails, mobiles, _userIds, team} = req.get()
    self = this

    if emails?.length > 200 or mobiles?.length > 200 or _userIds?.length > 200
      return callback(new Err('TOO_MANY_FIELDS'))

    if toString.call(_userIds) is '[object Array]'
      _userIds = _.uniq _userIds
      $userInvitees = Promise.resolve(_userIds).map (_userId) -> team.addMemberAsync _userId
    else $userInvitees = Promise.resolve([])

    if toString.call(emails) is '[object Array]'
      emails = _.uniq emails
      $emailInvitees = Promise.resolve(emails).map (email) ->
        conditions = email: email
        team.inviteAsync conditions
    else $emailInvitees = Promise.resolve([])

    if toString.call(mobiles) is '[object Array]'
      mobiles = _.uniq mobiles
      $mobileInvitees = Promise.resolve(mobiles).map (mobile) ->
        conditions = mobile: mobile
        team.inviteAsync conditions
    else $mobileInvitees = Promise.resolve([])

    # 邀请完成后发送邮件及推送信息
    afterInviteAsync = Promise.promisify self.afterInvite

    Promise.all [$userInvitees, $emailInvitees, $mobileInvitees]

    .spread (userInvitees, emailInvitees, mobileInvitees) ->
      invitees = [].concat userInvitees, emailInvitees, mobileInvitees
      # 如邀请者数量超过 0，则设置公告板 ID 供发送系统消息
      if invitees.length
        RoomModel.findOneAsync team: team._id, isGeneral: true
        .then (room) ->
          throw new Err('OBJECT_MISSING', 'general room') unless room?._id
          req.set '_roomId', room._id
          return invitees
      else invitees

    .map (invitee) -> afterInviteAsync.call self, req, res, invitee

    .nodeify callback

  @action 'removeMember', (req, res, callback) ->
    {_id, _userId, team} = req.get()
    team.removeMember _userId, (err) ->
      callback err, ok: 1
      return if err
      data = _teamId: _id, _userId: _userId
      res.broadcast "team:#{_id}", "team:leave", data
      team.createLeaveMessage _creatorId: _userId

  @action 'setMemberRole', (req, res, callback) ->
    {_id, role, _userId, team} = req.get()
    team.setMemberRole _userId, role, (err) ->
      data =
        _teamId: team._id
        _userId: _userId
        role: role
      if err
        callback err, data
      else
        res.broadcast "team:#{team._id}", "member:update", data
        callback null, data

  ###*
   * Refresh team's invite code
   * @param  {Request}   req
   * @param  {Response}   res
   * @param  {Function} callback
  ###
  @action 'refresh', (req, res, callback) ->
    {team, properties} = req.get()
    properties or= {}

    $team = Promise.resolve(team)

    if properties.inviteCode
      $team = $team.then (team) ->
        new Promise (resolve, reject) ->
          team.inviteCode = util.genInviteCode()
          team.updatedAt = new Date
          team.save (err, team) ->
            return reject(err) if err
            resolve team

    if properties.signCode
      $team = $team.then (team) -> team.refreshSignCodeAsync()

    $team.then (team) ->
      res.broadcast "team:#{team._id}", "team:update", team
      team

    .nodeify callback

  @action 'pinTarget', (req, res, callback) ->
    {_id, _sessionUserId, _targetId, type} = req.get()
    options =
      user: _sessionUserId
      team: _id
      target: _targetId
      type: type
      isPinned: true
      updatedAt: new Date
    NotificationModel.createByOptions options, callback

  @action 'unpinTarget', (req, res, callback) ->
    {_id, _sessionUserId, _targetId, type} = req.get()
    options =
      user: _sessionUserId
      team: _id
      target: _targetId
      type: type
      isPinned: false
      updatedAt: new Date
    NotificationModel.createByOptions options, callback

  @action 'joinByInviteCode', (req, res, callback) ->
    {inviteCode, _sessionUserId, sessionUser} = req.get()
    return callback(new Err('PARAMS_MISSING', 'inviteCode')) unless inviteCode
    $team = TeamModel.findOneAsync inviteCode: inviteCode

    .then (team) ->
      throw new Err('INVALID_INVITECODE') unless team
      team

    $isMember = $team.then (team) ->
      MemberModel.findOne
        team: team._id
        user: _sessionUserId
        isQuit: false
      .populate 'user'
      .execAsync()

    .then (member) -> if member then true else false

    Promise.all [$team, $isMember]

    .spread (team, isMember) ->
      if isMember
        callback null, team

      else
        team.addMemberAsync sessionUser

        .then (invitee) ->
          res.broadcast "team:#{team._id}", "team:join", invitee
          team.createJoinMessage _creatorId: _sessionUserId
          team

        .then -> callback null, team

  @action 'readByInviteCode', (req, res, callback) ->
    {inviteCode} = req.get()
    TeamModel.findOne inviteCode: inviteCode, (err, team) ->
      return callback(new Err('OBJECT_MISSING', 'team')) unless team
      callback err, team

  @action 'joinBySignCode', (req, res, callback) ->
    {signCode, _sessionUserId, _id} = req.get()
    TeamModel.joinBySignCode _id, _sessionUserId, signCode, (err, user) ->
      TeamModel.welcomeNewTeamMember _id, user._id, (err) ->
        callback err, user?.team

########################## HOOKS ##########################
  ###*
   * Check for signCode and add this user to this team
   * Used in inviting via qrcode on mobile platforms
  ###
  @action 'checkSignCode', (req, res, callback) ->
    {_id, _sessionUserId, signCode} = req.get()
    return callback() unless signCode?.length
    TeamModel.joinBySignCode _id, _sessionUserId, signCode, callback

  ###*
   * (post-hook of join)
   * Set the hasVisited property on team object
   * Set this property to true on member object
   * @param {Request}   req      [description]
   * @param {Response}   res      [description]
   * @param {Model}   team     [description]
   * @param {Function} callback [description]
  ###
  @action 'setMemberVisited', (req, res, team, callback) ->
    {member} = req.get()
    team.hasVisited = member.hasVisited

    member.hasVisited = true
    member.save()
    callback null, team

  # populate unread message/latest messages and other infomation of team
  @action 'attachTeamDetail', (req, res, team, callback) ->
    {_sessionUserId} = req.get()
    async.auto
      attachMembers: (callback) -> team.attachMembers callback
      attachRooms: (callback) -> team.attachRooms callback
      attachSignCode: (callback) -> team.attachSignCode callback
      attachInvitations: (callback) -> team.attachInvitations callback
      attachPrefs: ['attachMembers', (callback) ->
        team.attachPrefs _sessionUserId, callback
      ]
      filterPrivateRooms: ['attachRooms', (callback) ->
        RoomModel.filterPrivateRooms team.rooms, _sessionUserId, (err, rooms) ->
          team.rooms = rooms
          callback err
      ]
      # Filter the quit rooms
      attachMemberPrefs: ['filterPrivateRooms', (callback) ->
        RoomModel.attachMemberPrefs team.rooms, _sessionUserId, callback
      ]
      attachUnreadNums: ['attachMembers', 'attachMemberPrefs', (callback) ->
        team.attachUnreadNums _sessionUserId, callback
      ]
      attachLatestMessages: ['attachMembers', 'attachMemberPrefs', (callback) ->
        team.attachLatestMessages _sessionUserId, callback
      ]
      attachLatestReadMessageIds: ['attachMembers', 'attachMemberPrefs', (callback) ->
        team.attachLatestReadMessageIds _sessionUserId, callback
      ]
      attachPinnedAt: ['attachMembers', 'attachMemberPrefs', (callback) ->
        team.attachPinnedAt _sessionUserId, callback
      ]
    , (err) -> callback err, team

  # Update latest team / Broadcast messages / Create new join message
  @action 'afterJoin', (req, res, team) ->
    {_sessionUserId, signCode, socketId} = req.get()
    PreferenceModel.updateByUserId _sessionUserId, _latestTeamId: team._id
    # Subscribe the team channel
    res.join "team:#{team._id}" if socketId
    # Broadcast team:join if this user was new member of team
    if signCode
      me = null
      team.members.some (user) ->
        if "#{user._id}" is _sessionUserId
          me = user.toJSON()
          me._teamId = team._id
          me.team = team.toJSON virtuals: false
          return true
      res.broadcast "team:#{team._id}", "team:join", me if me
      team.createJoinMessage _creatorId: _sessionUserId

  ###*
   * Send invitationo email or sms text
   * Create welcome message by talkai
   * Broadcast messages
  ###
  @action 'afterInvite', (req, res, invitee, callback) ->
    {_sessionUserId, team, _roomId, lang} = req.get()
    if invitee.isInvite  # 邀请记录
      res.broadcast "team:#{team._id}", "invitation:create", invitee
    else  # 邀请成员
      res.broadcast "team:#{team._id}", "team:join", invitee
      res.broadcast "user:#{invitee._id}", "team:join", invitee
      team.createJoinMessage _creatorId: invitee._id, _roomId: _roomId

    inviteMailer.send _sessionUserId, invitee

    # Send sms invite message
    if invitee.isInvite and invitee.mobile
      $inviterName = UserModel.findOneAsync _id: _sessionUserId, 'name'
      .then (user) -> user?.name or ''

      $inviteSMSText = $inviterName.then (inviterName) ->
        i18n.fns(lang).inviteSMS inviterName, team.name, team.inviteUrl

      $inviteSMSText.then (smsText) ->
        util.sendSMS invitee.mobile, smsText,
          dailyRate: 1
          ip: req.headers['x-real-ip'] or req.ip
          _userId: invitee._id
          uid: req.get('uid')

      .catch (err) -> logger.warn err.stack

    # Create welcome message
    team.welcomeNewTeamMember invitee._id unless invitee.isInvite

    callback null, invitee

  @action 'afterLeave', (req, res) ->
    {_sessionUserId, _id, team, socketId} = req.get()
    data =
      _teamId: _id
      _userId: _sessionUserId
    res.broadcast "team:#{_id}", "team:leave", data
    # Unsubscribe to team channel
    res.leave "team:#{_id}" if socketId
    # Create new leave message
    team.createLeaveMessage _creatorId: _sessionUserId

  @action 'attachTeamsDetail', (req, res, teams, callback) ->
    {_sessionUserId} = req.get()

    $attachUnread = Promise.map teams, (team) -> team.attachUnreadNumsAsync _sessionUserId
    $attachSignCode = Promise.map teams, (team) -> team.attachSignCodeAsync()
    $attachPrefs = Promise.map teams, (team) -> team.attachPrefsAsync _sessionUserId

    Promise.all [$attachUnread, $attachSignCode, $attachPrefs]
    .spread -> teams
    .nodeify callback

  @action 'checkForNewNotice', (req, res, team) ->
    {_sessionUserId} = req.get()
    NoticeModel.checkForNewNotice _sessionUserId, team._id

  @action 'afterPin', (req, res) ->
    {_sessionUserId, _targetId, _id} = req.get()
    {action} = req
    switch action
      when 'pinTarget'
        event = "team:pin"
      when 'unpinTarget'
        event = "team:unpin"
      else return false
    data = _teamId: _id, _targetId: _targetId
    res.broadcast "user:#{_sessionUserId}", event, data

  @action 'skipTalkai', (req, res, callback) ->
    {_id, _userId, team} = req.get()
    $talkai = serviceLoader.getRobotOf 'talkai'
    $talkai.then (talkai) ->
      throw new Err('NO_PERMISSION') if "#{talkai._id}" is _userId
    .nodeify callback

  @action 'checkInvitations', (req, res, callback) ->
    {_id, sessionUser, _sessionUserId} = req.get()

    conditions = $or: []

    if sessionUser.phoneForLogin
      conditions.$or.push key: "mobile_#{sessionUser.phoneForLogin}"

    if sessionUser.emailForLogin
      conditions.$or.push key: "email_#{sessionUser.emailForLogin}"

    if sessionUser.unions?.length
      sessionUser.unions.forEach (union) ->
        conditions.$or.push key: "#{union.refer}_#{union.openId}"

    return callback() unless conditions.$or.length

    $invitations = InvitationModel.findAsync conditions

    $join = $invitations.map (invitation) ->

      if invitation._roomId and invitation._teamId
        $invitee = RoomModel.addTeamMemberAsync invitation._roomId, sessionUser
      else if invitation._teamId
        $invitee = TeamModel.addMemberAsync invitation._teamId, sessionUser
      else return invitation

      $invitee.then (invitee) ->
        # Broadcast join events and create join messages
        if invitation._roomId
          res.broadcast "team:#{invitation._teamId}", "room:join", invitee
          RoomModel.createJoinMessage invitation._roomId, invitee._id
        else
          res.broadcast "team:#{invitation._teamId}", "team:join", invitee
          TeamModel.welcomeNewTeamMember invitation._teamId, invitee._id
          TeamModel.createJoinMessage invitation._teamId, _creatorId: invitee._id

      .catch (err) -> logger.warn err.stack

      .then -> invitation

    .map (invitation) ->
      # Remove invitations
      invitation?.remove (err, invitation) ->
        return unless invitation?._teamId or err
        res.broadcast "team:#{invitation._teamId}", "invitation:remove", invitation

    $join.catch (err) -> logger.warn err.stack

    .then -> callback()

  ###*
   * Check union teams and sync them to talk service
   * Create team members or invitations when team has members
  ###
  @action 'checkUnionTeams', (req, res, callback) ->
    {_id, sessionUser, accountToken, refer} = req.get()
    return callback() unless sessionUser.accountId and sessionUser.unions?.length

    $unions = util.getAccountUserAsync(accountToken).then (user) -> user.unions

    $unions.map (union) ->
      return unless union.refer is refer and union.accessToken
      # Get syncer by its refer name
      syncer = syncers[union.refer]
      return unless syncer
      # Sync teams
      $teams = syncer.getTeamsAsync union

      .map (thirdTeam) ->
        thirdTeam.source = union.refer
        thirdTeam.creator = sessionUser._id
        TeamModel.syncThirdTeamAsync thirdTeam

      # Sync members
      if toString.call(syncer.getTeamMembersAsync) is '[object Function]'

        $syncMembers = $teams.map (team) ->

          $members = syncer.getTeamMembersAsync union, team

          .map (thirdMember) ->

            team.syncThirdMemberAsync thirdMember
            .catch (err) ->

          .filter (invitee) -> invitee

          .map (invitee) ->
            if invitee.isInvite
              res.broadcast "team:#{team._id}", "invitation:create", invitee
            else  # 邀请成员
              res.broadcast "team:#{team._id}", "team:join", invitee
              res.broadcast "user:#{invitee._id}", "team:join", invitee

          .catch (err) ->  # Ignore errors

      else $syncMembers = Promise.resolve()

      Promise.all [$teams, $syncMembers]

    .catch (err) -> logger.warn err.stack

    .then -> callback()

  ###*
   * Check target type and set type property
  ###
  @action 'checkTargetType', (req, res, callback) ->
    {_targetId} = req.get()
    $room = RoomModel.findOneAsync _id: _targetId, '_id'
    $user = UserModel.findOneAsync _id: _targetId, '_id'
    $story = StoryModel.findOneAsync _id: _targetId, '_id'

    Promise.all [$room, $user, $story]

    .spread (room, user, story) ->

      switch
        when room then type = 'room'
        when user then type = 'dms'
        when story then type = 'story'
        else return callback(new Err('INVALID_TARGET'))

      req.set 'type', type

    .nodeify callback

  @action 'filterSensitiveFromTeam', (req, res, team, callback) ->
    Promise.map team.members, (member) ->
      if member.prefs.hideMobile
        _user = member
      else
        _user = member.toJSON({hide: "", transform: true, virtuals: true, getters: true})
      _user

    .then (members) ->
      team.members = members
      team
    .nodeify callback

  @action 'filterSensitiveFromMembers', (req, res, members, callback) ->
    Promise.map members, (member) ->
      if member.prefs.hideMobile
        _user = member
      else
        _user = member.toJSON({hide: "", transform: true, virtuals: true, getters: true})
      _user

    .nodeify callback

  @action 'createActivityAfterInvite', (req, res, invitee) ->
    return if invitee?.isInvite or not invitee.name
    acitivity = new ActivityModel
      team: invitee._teamId
      creator: req.get('_sessionUserId')
      text: "{{__info-invite-team-member}} #{invitee.name}"
      isPublic: true
    acitivity.$save().catch (err) -> logger.warn err.stack
