_ = require 'lodash'
async = require 'async'
Err = require 'err1st'
qs = require 'querystring'
validator = require 'validator'
Promise = require 'bluebird'
logger = require 'graceful-logger'
jwt = require 'jsonwebtoken'
{redis, limbo} = require '../components'
config = require 'config'
util = require '../util'
app = require '../server'

{
  TeamModel
  UserModel
  DeviceTokenModel
  PreferenceModel
  MessageModel
  NoticeModel
  NotificationModel
} = limbo.use 'talk'

module.exports = userController = app.controller 'user', ->

  @mixin require './mixins/general'

  @ensure 'socketId', only: 'subscribe unsubscribe'
  @ensure 'inviteCode', only: 'via'

  @before 'setSessionUser', only: 'me landing'

  @after 'afterUpdate', only: 'update', parallel: true
  @after 'appendSensitiveToUser', only: 'me update'

  editableFields = ['name', 'avatarUrl']

  _redirect = (req, res, callback) ->
    {account, _sessionUserId} = req.get()
    res.publish "user:#{_sessionUserId}", "integration:gettoken", account
    res.render 'app/redirect'

  @action 'read', (req, res, callback) ->
    {keyword, emails, mobiles} = req.get()

    if keyword?
      if validator.isEmail keyword
        conditions = emailForLogin: keyword.trim()
      else if /^\+?\d+$/.test keyword
        conditions = phoneForLogin: keyword.trim()
      else
        return callback(new Err('PARAMS_INVALID', "keyword #{keyword}"))

    else if emails or mobiles
      emails = emails.split(',') if toString.call(emails) is '[object String]'
      mobiles = mobiles.split(',') if toString.call(mobiles) is '[object String]'
      if emails?.length > 500 or mobiles?.length > 500
        return callback(new Err('TOO_MANY_FIELDS'))
      if mobiles
        conditions = phoneForLogin: $in: mobiles
      else if emails
        conditions = emailForLogin: $in: emails

    else
      return callback(new Err('PARAMS_MISSING', "keyword, mobiles, emails"))

    UserModel.find conditions, callback

  @action 'readOne', (req, res, callback) -> UserModel.findOne _id: req.get('_id'), callback

  @action 'me', (req, res, callback) ->
    {_sessionUserId, sessionUser} = req.get()

    $preference = PreferenceModel.updateByUserIdAsync sessionUser._id, {}

    $user = Promise.resolve(sessionUser)

    Promise.all [$user, $preference]

    .spread (user, preference) ->
      user.preference = preference
      user

    .nodeify callback

  @action 'update', (req, res, callback) ->
    {_sessionUserId} = req.get()
    conditions = _id: _sessionUserId
    update = _.pick req.get(), editableFields
    return callback(new Err 'PARAMS_MISSING', editableFields) if _.isEmpty(update)
    UserModel.findOneAndSave _id: _sessionUserId, update, callback

  # Broadcast new user infomation to team members
  @action 'afterUpdate', (req, res, user) ->
    user.findTeamIds (err, _teamIds = []) ->
      eventRooms = _teamIds.map (_teamId) -> "team:#{_teamId}"
      res.broadcast eventRooms, 'user:update', user unless _.isEmpty(eventRooms)

  @action 'signout', (req, res, callback) ->
    {_sessionUserId, clientType, clientId, socketId, token} = req.get()
    cookieOptions = domain: config.sessionDomain
    res.clearCookie config.accountId, cookieOptions
    delete req.session._sessionUserId if req.session?

    if clientType or clientId
      options = user: _sessionUserId
      options.type = clientType if clientType

      if clientId and token
        options.$or = [
          clientId: clientId
        ,
          token: token
        ]
      else if clientId
        options.clientId = clientId
      else if token
        options.token = token

      DeviceTokenModel.remove options, ->

    callback null, ok: 1

    res.leave "user:#{_sessionUserId}" if socketId

  @action 'subscribe', (req, res, callback) ->
    {socketId} = req.get()
    return callback(new Err('PARAMS_MISSING', 'socketId')) unless socketId
    res.join "user:#{req.get('_sessionUserId')}", callback

  @action 'unsubscribe', (req, res, callback) ->
    {socketId} = req.get()
    return callback(new Err('PARAMS_MISSING', 'socketId')) unless socketId
    res.leave "user:#{req.get('_sessionUserId')}", callback

  # Login via invite Code
  # Just set cookie
  @action 'via', (req, res, callback) ->
    {inviteCode} = req.get()
    res.redirect 302, util.buildPageUrl() + "/invite/#{inviteCode}"

  ###*
   * 保留作为 Github，微博聚合授权入口
   * @todo 简聊账号系统支持Github，微博登录之后，去除此方法
  ###
  @action 'landing', (req, res, callback) ->

    {_sessionUserId, sessionUser, refer, accountToken} = req.get()

    return callback(new Err('INVALID_TOKEN')) unless sessionUser.accountId
    $unions = util.getAccountUserAsync(accountToken).then (user) -> user.unions

    $union = $unions.filter (union) ->
      return true if union.refer is refer and union.accessToken

    .then (unions) ->
      throw new Err('INVALID_REFER') unless unions.length

      arefer = refer
      atoken = unions[0].accessToken
      req.set 'account', unions[0]

      return _redirect(req, res, callback) if atoken and arefer
      return callback(new Err('NO_PERMISSION'))

    .catch callback

  # Heartbeat
  # Scope: version
  @action 'state', (req, res, callback) ->
    {scope, _teamId, _sessionUserId, clientType} = req.get()
    scopes = scope?.split(',') or ['version']
    data = {}
    async.auto
      version: (callback) ->
        return callback() unless 'version' in scopes
        redis.get 'talk:version', (err, version) ->
          data.version = version or null
          callback err
      checkfornewnotice: (callback) ->
        return callback() unless 'checkfornewnotice' in scopes and _teamId
        NoticeModel.checkForNewNotice _sessionUserId, _teamId, callback
      unread: (callback) ->
        return callback() unless 'unread' in scopes and _teamId
        NotificationModel.findUnreadNums _sessionUserId, _teamId, (err, unreadNums) ->
          data.unread = unreadNums
          callback()
      onlineweb: (callback) ->
        return callback() unless 'onlineweb' in scopes
        redis.get "online_web_#{_sessionUserId}", (err, online) ->
          data.onlineweb = if online then 1 else 0
          callback()
      setOnlineState: (callback) ->
        switch clientType
          when 'xiaomi', 'android', 'miui' then clientType = 'android'
          when 'ios' then clientType = 'ios'
          else  clientType = 'web'
        redis.setex "online_#{clientType}_#{_sessionUserId}", 120, 1, callback
    , (err) -> callback err, data

  @action 'appendSensitiveToUser', (req, res, user, callback) ->
    $user = Promise.resolve(user)

    $user.then (user)->
      user.toJSON({hide: "", transform: true, virtuals: true, getters: true})
    .nodeify callback
