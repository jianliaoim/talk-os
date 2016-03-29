###*
 * Mail controller, only for testing jade mail views
###
path = require 'path'
Err = require 'err1st'
Promise = require 'bluebird'
moment = require 'moment'
jade = require 'jade'
limbo = require 'limbo'
juice = require 'juice'
logger = require 'graceful-logger'

util = require '../util'
app = require '../server'
mailers = require '../mailers'

{MessageModel, UserModel, RoomModel, TeamModel} = limbo.use 'talk'

module.exports = mailController = app.controller 'mail', ->

  @ensure '_teamId', only: 'invite dm'
  @ensure '_toId', only: 'dm'
  @ensure '_roomId', only: 'rm'

  @action 'render', (req, res, callback) ->
    {type} = req.get()
    if @[type] then @[type].apply(this, arguments) else callback(new Err('NO_PERMISSION'))

  ###*
   * Direct message
   * @param  {[type]} req [description]
   * @param  {[type]} res [description]
   * @return {[type]}     [description]
  ###
  @action 'dm', (req, res, callback) ->
    {_sessionUserId, _toId, _teamId} = req.get()
    email = {}

    userPromise = UserModel.findOneAsync _id: _sessionUserId
    senderPromise = UserModel.findOneAsync _id: _toId
    teamPromise = TeamModel.findOneAsync _id: _teamId
    messagePromise = MessageModel.findMessagesWithUserAsync _toId, _sessionUserId, _teamId, { isSystem: false, limit: 20 }

    Promise.all [userPromise, senderPromise, teamPromise, messagePromise]
    .then ([user, sender, team, messages]) ->

      messages = messages.map (message) ->
        message.formatedDate = moment(new Date(message.createdAt)).format('HH:mm')
        message
      email.messages = messages
      email.user = user
      email.sender = sender
      email.clickUrl = util.buildTeamUrl _teamId, null, sender._id
      email.team = team
      email.num = '20+'
      email.subject = "[简聊] #{email.sender?.name}给你发送了新消息"
      template = 'direct-message'

      mailers.dmMailer._render email
      .then (email) -> res.end email.html

  ###*
   * Room message
   * @param  {[type]} req [description]
   * @param  {[type]} res [description]
   * @return {[type]}     [description]
  ###
  @action 'rm', (req, res, callback) ->
    {_sessionUserId, _roomId} = req.get()
    email = {}

    userPromise = UserModel.findOneAsync _id: _sessionUserId
    messagePromise = MessageModel.findMessagesFromRoomAsync _roomId, { isSystem: false, limit: 20 }
    roomPromise = RoomModel.findOneAsync _id: _roomId

    Promise.all [userPromise, roomPromise, messagePromise]
    .then ([user, room, messages]) ->

      messages = messages.map (message) ->
        message.formatedDate = moment(new Date(message.createdAt)).format('HH:mm')
        message
      email.messages = messages
      email.room = room
      email.clickUrl = util.buildTeamUrl room._teamId, room._id
      email.user = user
      email.num = '20+'
      email.subject = "[简聊] 来自#{room.topic}的新消息"

      mailers.rmMailer._render email
      .then (email) -> res.end email.html

  ###*
   * Guest message
   * @param  {[type]} req [description]
   * @param  {[type]} res [description]
   * @return {[type]}     [description]
  ###
  @action 'gm', (req, res, callback) ->
    {_sessionUserId, _roomId} = req.get()
    email = {}

    userPromise = UserModel.findOneAsync _id: _sessionUserId
    messagePromise = MessageModel.findMessagesFromRoomAsync _roomId, { isSystem: false, limit: 20 }
    roomPromise = RoomModel.findOneAsync _id: _roomId

    Promise.all [userPromise, roomPromise, messagePromise]
    .then ([user, room, messages]) ->

      messages = messages.map (message) ->
        message.formatedDate = moment(new Date(message.createdAt)).format('HH:mm')
        message
      email.messages = messages
      email.room = room
      email.clickUrl = util.buildTeamUrl room._teamId, room._id
      email.user = user
      email.num = '20+'
      email.subject = "[简聊] 话题 “#{room.topic}” 中的聊天记录"

      mailers.gmMailer._render email
      .then (email) -> res.end email.html

  @action 'invite', (req, res, callback) ->
    {_sessionUserId, _teamId} = req.get()
    userPromise = UserModel.findOneAsync _id: _sessionUserId
    teamPromise = TeamModel.findOneAsync _id: _teamId

    email = {}

    Promise.all [userPromise, teamPromise]
    .then ([sender, team]) ->

      email.sender = sender
      email.team = team
      email.label = "团队"
      email.subject = "[简聊] #{sender.name}邀请你加入#{email.label}"
      email.titleName = team.name
      email.redirectUrl = util.buildTeamUrl team._id

      mailers.inviteMailer._render email
      .then (email) -> res.end email.html

  @action 'login', (req, res, callback) ->
    {_sessionUserId} = req.get()
    userPromise = UserModel.findOneAsync _id: _sessionUserId

    email = {}

    Promise.all [userPromise]
    .then ([user]) ->
      email.user = user
      email.subject = "[简聊] 欢迎来到简聊"
      email.redirectUrl = util.buildIndexUrl()
      email.redirectTip = '点击按钮访问简聊：'
      email.redirectBtnTip = '访问简聊'

      mailers.loginMailer._render email
      .then (email) -> res.end email.html
