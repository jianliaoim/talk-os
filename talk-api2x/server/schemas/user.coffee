###*
 * Indexes:
 * db.users.ensureIndex({emailDomain: 1}, {sparse: true, background: true})
 * db.users.ensureIndex({accountId: 1}, {unique: true, sparse: true, background: true})
 * db.users.ensureIndex({emailForLogin: 1}, {unique: true, sparse: true, background: true})
 * db.users.ensureIndex({phoneForLogin: 1}, {unique: true, sparse: true, background: true})
 * db.users.ensureIndex({service: 1}, {unique: true, sparse: true, background: true})
 * db.users.ensureIndex({'unions.refer': 1, 'unions.openId': 1}, {unique: true, sparse: true, background: true})
###
{Schema} = require 'mongoose'
pinyin = require 'pinyin'
request = require 'request'
Promise = require 'bluebird'
config = require 'config'
Err = require 'err1st'
util = require '../util'

UnionSchema = new Schema
  refer: type: String
  openId: type: String
  name: type: String
  avatarUrl: type: String

module.exports = UserSchema = new Schema
  name:
    type: String
    set: (val) ->
      @pinyin = pinyin(val, style: pinyin.STYLE_NORMAL).join('').toLowerCase()
      @pinyins = util.arrHorizon(pinyin(val, heteronym: true, style: pinyin.STYLE_NORMAL)).map (val) -> val.toLowerCase()
      @py = pinyin(val, style: pinyin.STYLE_FIRST_LETTER).join('').toLowerCase()
      @pys = util.arrHorizon(pinyin(val, heteronym: true, style: pinyin.STYLE_FIRST_LETTER)).map (val) -> val.toLowerCase()
      val
    get: (name) -> name or ''
  avatarUrl: type: String, default: util.randomAvatarUrl
  sourceId: type: String
  source: type: String
  description: type: String
  email: type: String, get: (email) -> email or @emailForLogin   # 仅用于显示，例如访客填写的 Email 信息
  mobile: type: String, get: (mobile) -> mobile or @phoneForLogin   # 仅用于显示
  emailDomain: type: String
  accountId: type: String
  from: type: String, default: 'register'
  pinyin: type: String
  pinyins: type: Array
  py: type: String
  pys: type: Array
  isRobot: type: Boolean, default: false
  isGuest: type: Boolean, default: false
  service: type: String  # 标识机器人账号对应的服务
  subAccountSid: type: String
  phoneForLogin: type: String
  emailForLogin: type: String, lowercase: true, set: (val) ->
    if val?.indexOf('@') > -1
      [name, domain] = val.split('@')
      @emailDomain = domain
    else
      @emailDomain = undefined
    return val
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
  unions: [UnionSchema]
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
    transform: (doc, ret, options) ->
      if options.hide?
        options.hide.split(' ').forEach (prop) ->
          if prop
            delete ret[prop];
      else
        delete ret.mobile
        delete ret.phoneForLogin
      ret
  toJSON:
    virtuals: true
    getters: true
    transform: (doc, ret, options) ->
      if options.hide?
        options.hide.split(' ').forEach (prop) ->
          if prop
            delete ret[prop];
      else
        delete ret.mobile
        delete ret.phoneForLogin
      ret
# ============================== Virtuals ==============================

UserSchema.virtual 'prefs'
  .get -> @_prefs
  .set (@_prefs) -> @_prefs

UserSchema.virtual 'preference'
  .get -> @_preference
  .set (@_preference) -> @_preference

UserSchema.virtual 'role'
  .get -> @_role
  .set (@_role) -> @_role

UserSchema.virtual 'unread'
  .get -> @_unread
  .set (@_unread) -> @_unread

UserSchema.virtual '_latestReadMessageId'
  .get -> @__latestReadMessageId
  .set (@__latestReadMessageId) -> @__latestReadMessageId

UserSchema.virtual 'pinnedAt'
  .get -> @_pinnedAt
  .set (@_pinnedAt) -> @_pinnedAt

UserSchema.virtual 'isPinned'
  .get -> @_isPinned
  .set (@_isPinned) -> @_isPinned

UserSchema.virtual '_teamId'
  .get -> @__teamId or @team?._id
  .set (@__teamId) -> @__teamId

UserSchema.virtual '_roomId'
  .get -> @__roomId or @room?._id
  .set (@__roomId) -> @__roomId

UserSchema.virtual 'team'
  .get -> @_team
  .set (@_team) -> @_team

UserSchema.virtual 'room'
  .get -> @_room
  .set (@_room) -> @_room

UserSchema.virtual 'voip'
  .get -> @_voip
  .set (@_voip) -> @_voip

# ============================== Methods ==============================
UserSchema.methods.findTeamIds = (callback = ->) ->
  MemberModel = @model 'Member'
  MemberModel.find
    user: @_id
    team: $ne: null
    isQuit: false
  , (err, members = []) ->
    _teamIds = members
      .map (member) -> member._teamId
      .filter (_teamId) -> _teamId
    callback err, _teamIds

UserSchema.methods.genName = ->
  user = this
  name = ''
  if user.phoneForLogin?.length
    name = user.phoneForLogin[0...3] + '***' + user.phoneForLogin[-3..]
  else if user.emailForLogin?.split?('@')?[0]
    name = user.emailForLogin?.split?('@')?[0]
  else if user.unions?[0]?.name
    name = user.unions?[0]?.name
  name

# ============================== Statics ==============================
UserSchema.statics.syncUserFromAccount = (accountToken, callback) ->
  UserModel = this

  $accountUser = util.getAccountUserAsync accountToken

  $user = $accountUser.then (accountUser) ->

    UserModel.findOneAsync accountId: accountUser._id

  $user = Promise.all [$user, $accountUser]

  .spread (user, accountUser) ->
    user = new UserModel unless user
    user.accountId = accountUser._id

    # 收到新的手机号码，则解绑所有其他用户的手机号，绑定到当前用户
    if accountUser.phoneNumber and accountUser.phoneNumber isnt user.phoneForLogin
      $removeMobile = UserModel.updateAsync
        phoneForLogin: accountUser.phoneNumber
      ,
        $unset:
          phoneForLogin: 1
          mobile: 1
    else $removeMobile = Promise.resolve()

    # 移除其他用户的重复邮箱
    if accountUser.emailAddress and accountUser.emailAddress isnt user.emailForLogin
      $removeEmail = UserModel.updateAsync
        emailForLogin: accountUser.emailAddress
      ,
        $unset:
          emailForLogin: 1
          email: 1
    else $removeEmail = Promise.resolve()

    # 移除其他用户的第三方账号
    unions = accountUser.unions.filter (union) ->
      hasAccount = user.unions.some (_union) -> _union.openId is union.openId and _union.refer is union.refer
      not hasAccount
    $removeUnions = Promise.resolve(unions).map (union) ->
      UserModel.updateAsync
        "unions.refer": union.refer
        "unions.openId": union.openId
      ,
        $pull:
          unions:
            refer: union.refer
            openId: union.openId

    Promise.all [$removeMobile, $removeEmail, $removeUnions]
    .then ->
      # 强制覆盖的 Account 属性
      user.phoneForLogin = accountUser.phoneNumber
      user.emailForLogin = accountUser.emailAddress
      user.unions = accountUser.unions
      # 其余属性
      user.mobile or= accountUser.phoneForLogin
      user.email or= accountUser.emailAddress
      user.name or= user.genName()

      user.updatedAt = new Date
      user.$save()

  $user.nodeify callback

###*
 * Init user infomation from accountToken
 * 1. Sync user from account service
 * @param  {String}   accountToken
###
UserSchema.statics.initByAccountToken = (accountToken, callback) ->
  UserModel = this
  # Sync user from account service
  $user = UserModel.syncUserFromAccountAsync accountToken

  $user.nodeify callback
