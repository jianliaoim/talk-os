{Schema} = require 'mongoose'
Err = require 'err1st'
jwt = require 'jsonwebtoken'
config = require 'config'
_ = require 'lodash'
bcrypt = require 'bcryptjs'

module.exports = UserSchema = new Schema
  password: type: String
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
    transform: (doc, ret, options) ->
      delete ret.password
      ret
  toJSON:
    virtuals: true
    getters: true
    transform: (doc, ret, options) ->
      delete ret.password
      ret

UserSchema.virtual 'accountToken'
  .get -> @_accountToken
  .set (@_accountToken) -> @_accountToken

UserSchema.virtual 'wasNew'
  .get -> @_wasNew or false
  .set (@_wasNew) -> @_wasNew

UserSchema.virtual 'login'
  .get -> @_login
  .set (@_login) -> @_login

UserSchema.virtual 'unions'
  .get -> @_unions or []
  .set (@_unions) -> @_unions

UserSchema.virtual 'phoneNumber'
  .get -> @_phoneNumber
  .set (@_phoneNumber) -> @_phoneNumber

UserSchema.virtual 'emailAddress'
  .get -> @_emailAddress
  .set (@_emailAddress) -> @_emailAddress

UserSchema.virtual 'refer'
  .get -> @_refer
  .set (@_refer) -> @_refer

UserSchema.virtual 'openId'
  .get -> @_openId
  .set (@_openId) -> @_openId

UserSchema.virtual 'name'
  .get -> @_name
  .set (@_name) -> @_name

UserSchema.virtual 'showname'
  .get -> @_showname
  .set (@_showname) -> @_showname

##################### METHODS #####################

UserSchema.methods.genAccountToken = (payload = {}) ->
  jwt.sign _.assign({}, payload, _id: @_id),
    config.accountCookieSecret
  ,
    expiresIn: config.accountCookieExpires
    noTimestamp: true

UserSchema.methods.genPassword = (rawPassword) ->
  bcrypt.hashSync rawPassword, 8

UserSchema.methods.verifyPassword = (rawPassword, callback) ->
  user = this
  return callback(new Err('LOGIN_VERIFY_FAILED')) unless user.password?.length
  bcrypt.compare rawPassword, user.password, (err, matched) ->
    return callback(new Err('LOGIN_VERIFY_FAILED')) unless matched
    callback err, user

##################### STATICS #####################

UserSchema.statics.verifyAccountToken = (accountToken, callback) ->
  try
    accountObj = jwt.verify accountToken, config.accountCookieSecret
  catch err

  return callback(new Err('ACCESS_FAILED')) unless accountObj?._id
  UserModel = this
  UserModel.findOne _id: accountObj?._id, (err, user) ->
    return callback(new Err('OBJECT_MISSING', "user #{accountObj._id}")) unless user
    user.login = accountObj.login
    callback err, user

UserSchema.pre 'save', (next) ->
  # 标识用户是否为新注册
  @wasNew = true if @isNew
  next()
