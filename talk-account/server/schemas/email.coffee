###*
 * db.emails.ensureIndex({emailAddress: 1}, {unique: true, background: true})
 * db.emails.ensureIndex({user: 1}, {unique: true, background: true})
###

{Schema} = require 'mongoose'
Err = require 'err1st'
redis = require '../components/redis'
Promise = require 'bluebird'
shortid = require 'shortid'
util = require '../util'

module.exports = EmailSchema = new Schema
  emailAddress: type: String, trim: true
  user: type: Schema.Types.ObjectId, ref: 'User'
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

EmailSchema.virtual 'login'
  .get -> 'email'

###*
 * 生成绑定信息随机码
 * @return {String} bindCode 随机码
###
EmailSchema.methods.genBindCode = (callback) ->
  bindCode = shortid()
  cacheKey = "emailbindcode:#{bindCode}"
  data =
    _id: @_id
    showname: @emailAddress
  redis.setex cacheKey, 600, JSON.stringify(data), (err) ->
    callback err, bindCode

############################ STATICS ############################
#
###*
 * 验证 bindCode，获取对应 email 对象
 * @return {Model} email 对象
###
EmailSchema.statics.verifyBindCode = (bindCode, callback) ->
  cacheKey = "emailbindcode:#{bindCode}"
  EmailModel = this
  redis.get cacheKey, (err, data) ->
    try
      {_id} = JSON.parse data
    catch err
    return callback(new Err('VERIFY_FAILED')) unless _id
    EmailModel.findOne _id: _id, (err, email) ->
      return callback(new Err('OBJECT_MISSING', 'email')) unless email
      redis.del cacheKey
      callback err, email

###*
 * 保存邮箱验证码
 * @param  {Object} options with emailAddress
 * @param  {Function} callback
 * @return {Object} randomCode: shortId
 * @todo 验证手机号格式
###
EmailSchema.statics.saveVerifyCode = (options, callback = ->) ->
  randomCode = shortid()
  cacheKey = "emailverifycode:#{randomCode}"

  # 保存新的 verify code
  verifyCode = "#{Math.random()}"[2...6]
  data =
    verifyCode: verifyCode
    emailAddress: options.emailAddress
    createdAt: Date.now()

  $verifyCode = redis.setexAsync cacheKey, 3600, JSON.stringify data
  .then -> verifyCode

  Promise.all [$verifyCode]

  .spread (verifyCode) ->
    randomCode: randomCode
    verifyCode: verifyCode

  .nodeify callback

EmailSchema.statics.verify = (randomCode, verifyCode, callback) ->
  cacheKey = "emailverifycode:#{randomCode}"

  redis.get cacheKey, (err, data) ->
    try
      verifyData = JSON.parse data
    catch err

    verifyData or= {}

    if verifyData.verifyCode?.length and verifyData.verifyCode is verifyCode and
       verifyData.emailAddress?.length
      # 邮箱存在且验证码正确
      redis.del cacheKey
      return callback null, verifyData

    callback(new Err('VERIFY_FAILED'))
