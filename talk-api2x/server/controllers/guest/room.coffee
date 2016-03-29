_ = require 'lodash'
Err = require 'err1st'
async = require 'async'
{gmMailer} = require '../../mailers'
util = require '../../util'
app = require '../../server'
{limbo} = require '../../components'

{
  RoomModel
  MemberModel
  PreferenceModel
  MessageModel
  NotificationModel
} = limbo.use 'talk'

module.exports = roomController = app.controller 'guest/room', ->

  @ensure 'guestToken', only: 'readOne join'
  @ensure 'prefs', only: 'updatePrefs'

  @after 'attachRoomDetail', only: 'join'
  @after 'afterJoin', only: 'join', parallel: true
  @after 'afterLeave', only: 'leave', parallel: true

  userFields = ['_id', 'name', 'avatarUrl', 'pinyin', 'pinyins', 'py', 'pys', 'isGuest', 'prefs']

  _createJoinMessage = (_userId, room) ->
    message = new MessageModel
      _creatorId: _userId
      _teamId: room._teamId
      _roomId: room._id
      body: '{{__info-join-room}}'
      isSystem: true
      icon: 'join-room'

    message.save()

  _createLeaveMessage = (_userId, room) ->
    message = new MessageModel
      _creatorId: _userId
      _teamId: room._teamId
      _roomId: room._id
      body: '{{__info-leave-room}}'
      isSystem: true
      icon: 'leave-room'

    message.save()

  @action 'readOne', (req, res, callback) ->
    {guestToken} = req.get()
    RoomModel
    .findOne guestToken: guestToken
    .populate 'team'
    .exec (err, room) ->
      return callback(new Err('OBJECT_MISSING', "room #{guestToken}")) unless room
      callback err, room

  @action 'join', (req, res, callback) ->
    {guestToken, _sessionUserId} = req.get()

    async.waterfall [

      (next) -> RoomModel.findOne guestToken: guestToken, next

      (room, next) ->
        return callback(new Err('OBJECT_MISSING', "room #{guestToken}")) unless room
        req.set 'room', room
        MemberModel.findOne
          room: room._id
          user: _sessionUserId
          isQuit: false
        , next

      (member, next) ->
        room = req.get 'room'

        if member
          room.joinDate = member.createdAt
          return next null, room

        room.addMember _sessionUserId, (err) ->
          req.newJoined = true
          room.joinDate = new Date
          next err, room

    ], callback

  @action 'leave', (req, res, callback) ->
    {_sessionUserId, _id} = req.get()
    RoomModel.removeMember _id, _sessionUserId, callback

  @action 'attachRoomDetail', (req, res, room, callback) ->
    {_sessionUserId} = req.get()
    async.auto
      attachMembers: (callback) ->
        room.attachMembers (err, room) ->
          return callback(err, room) unless room?.members
          room.members = room.members.map (user) ->
            if "#{user._id}" is _sessionUserId then user else _.pick user, userFields
          callback err, room
      attachPrefs: ['attachMembers', (callback) ->
        room.attachPrefs _sessionUserId, callback
      ]
      # Guest should not read the messages before joined time
      attachLatestMessages: (callback) ->
        options = limit: 30
        options._id = $gt: util.getIdByDate(room.joinDate) unless room.isGuestVisible
        MessageModel.findMessagesFromRoom room._id, options, (err, messages = []) ->
          room.latestMessages = messages.map (message) ->
            {creator} = message
            creator or= {}
            message.creator = _.pick creator, userFields
            message
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

  @action 'afterJoin', (req, res, room) ->
    {_id, _sessionUserId} = req.get()
    PreferenceModel.updateByUserId _sessionUserId, _latestRoomId: room._id
    if req.newJoined  # Broadcast new member
      me = null
      room.members.some (user) ->
        if "#{user._id}" is _sessionUserId
          me = user.toJSON?() or user
          me._roomId = room._id
          me._teamId = room._teamId
          return true
        return false
      res.broadcast "team:#{room._teamId}", "room:join", me
      _createJoinMessage _sessionUserId, room

  ###*
   * Send message history to the left guest
   * Send leave message to other room members
   * @param  {[type]} req  [description]
   * @param  {[type]} res  [description]
   * @param  {[type]} room [description]
  ###
  @action 'afterLeave', (req, res, room) ->
    {_id, _sessionUserId} = req.get()
    data =
      _roomId: room._id
      _userId: _sessionUserId
      _teamId: room._teamId
    res.broadcast "team:#{room._teamId}", "room:leave", data
    _createLeaveMessage _sessionUserId, room
    gmMailer.send _sessionUserId, room._id
