_ = require 'lodash'
async = require 'async'
Err = require 'err1st'
jwt = require 'jsonwebtoken'
config = require 'config'
app = require '../../server'
util = require '../../util'
{gmMailer} = require '../../mailers'
{redis, schedule, limbo} = require '../../components'

{
  UserModel
  MemberModel
  MessageModel
  RoomModel
} = limbo.use 'talk'

module.exports = userController = app.controller 'guest/user', ->

  @ensure 'name', only: 'create'

  @after 'afterSignout', only: 'signout', parallel: true

  editableFields = [
    'name'
    'email'
    'avatarUrl'
  ]

  _createLeaveMessage = (_userId, room) ->
    message = new MessageModel
      _creatorId: _userId
      _teamId: room._teamId
      _roomId: room._id
      body: '{{__info-leave-room}}'
      isSystem: true
      icon: 'leave-room'

    message.save()

  @action 'create', (req, res, callback) ->
    {name, email, avatarUrl} = req.get()
    user = new UserModel
      name: name
      email: email
      avatarUrl: avatarUrl or util.randomAvatarUrl()
      isGuest: true
    user.save (err, user) ->
      if user
        cookieOptions =
          domain: config.guestSessionDomain
          httpOnly: true
        guestToken = jwt.sign _id: user._id,
          config.guestSessionSecret
        ,
          noTimestamp: true
        res.cookie config.guestSessionKey, guestToken, cookieOptions
      callback err, user

  @action 'update', (req, res, callback) ->
    {_sessionUserId, name, email} = req.get()
    conditions = _id: _sessionUserId
    update = _.pick req.get(), editableFields
    return callback(new Err 'PARAMS_MISSING', editableFields) if _.isEmpty(update)
    UserModel.findOneAndSave conditions, update, callback

  @action 'signout', (req, res, callback) ->
    {_sessionUserId} = req.get()
    cookieOptions = domain: config.guestSessionDomain
    res.clearCookie config.guestSessionKey, cookieOptions
    callback null, ok: 1

  @action 'afterSignout', (req, res) ->
    {_sessionUserId, socketId} = req.get()

    res.leave "user:#{_sessionUserId}" if socketId

    async.waterfall [

      (next) ->
        MemberModel.find
          user: _sessionUserId
          isQuit: false
        , next

      (members, next) ->
        return next() unless members?.length

        async.each members, (member, next) ->

          return next() unless member._roomId

          RoomModel.removeMember member._roomId, _sessionUserId, (err, room) ->
            next err
            return if err or not room
            data =
              _roomId: room._id
              _userId: _sessionUserId
              _teamId: room._teamId
            res.broadcast "team:#{room._teamId}", "room:leave", data
            _createLeaveMessage _sessionUserId, room
            gmMailer.send _sessionUserId, room._id

        , next

    ]

  @action 'state', (req, res, callback) ->
    {_sessionUserId} = req.get()

    schedule.addTask
      id: 'sweepGuest' + _sessionUserId
      action: 'sweepGuest'
      executeAt: Date.now() + 3600000  # 1 hour later
      args: [_sessionUserId]

    callback null, ok: 1
