###*
 * db.mobiles.ensureIndex({phoneNumber: 1}, {unique: true, background: true})
 * db.mobiles.ensureIndex({user: 1}, {unique: true, background: true})
###

{Schema} = require 'mongoose'
Err = require 'err1st'
Promise = require 'bluebird'
redis = require '../components/redis'
shortid = require 'shortid'
util = require '../util'

module.exports = MobileSchema = new Schema
  phoneNumber: type: String, trim: true
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

MobileSchema.virtual 'login'
  .get -> 'mobile'

MobileSchema.virtual 'showname'
  .get -> @phoneNumber

###*
 * 生成绑定信息随机码
 * @return {String} bindCode 随机码
###
MobileSchema.methods.genBindCode = (callback) ->
  bindCode = shortid()
  cacheKey = "mobilebindcode:#{bindCode}"
  data =
    _id: @_id
    showname: @showname
  redis.setex cacheKey, 600, JSON.stringify(data), (err) ->
    callback err, bindCode

############################ STATICS ############################

###*
 * 获取绑定信息随机码
 * @return {String} showname 账号名称
###
MobileSchema.statics.getBindData = (bindCode, callback) ->
  cacheKey = "mobilebindcode:#{bindCode}"

  redis.get cacheKey, (err, data) ->
    try
      {showname} = JSON.parse data
    catch err

    if showname?.length
      return callback null,
        showname: showname
    else
      return callback(new Err('OBJECT_MISSING', 'showname'))

###*
 * 验证 bindCode，获取对应 mobile 对象
 * @return {Model} mobile 对象
###
MobileSchema.statics.verifyBindCode = (bindCode, callback) ->
  cacheKey = "mobilebindcode:#{bindCode}"
  MobileModel = this
  redis.get cacheKey, (err, data) ->
    try
      {_id} = JSON.parse data
    catch err
    return callback(new Err('VERIFY_FAILED')) unless _id
    MobileModel.findOne _id: _id, (err, mobile) ->
      return callback(new Err('OBJECT_MISSING', 'mobile')) unless mobile
      redis.del cacheKey
      callback err, mobile

MobileSchema.statics.getVerifyData = (randomCode, callback) ->
  cacheKey = "smsverifycode:#{randomCode}"

  redis.get cacheKey, (err, data) ->
    try
      {createdAt, phoneNumber, verifyCode} = JSON.parse data
    catch err

    if phoneNumber?.length
      if createdAt?
        return callback null,
          createdAt: createdAt
          phoneNumber: phoneNumber
      else
        return callback(new Err('OBJECT_MISSING', 'createdAt'))
    else
      return callback(new Err('OBJECT_MISSING', 'phoneNumber'))

###*
 * 发送手机验证码
 * @param  {Object} options with phoneNumber
 * @param  {Function} callback
 * @return {Object} randomCode: shortId
 * @todo 验证手机号格式
###
MobileSchema.statics.sendVerifyCode = (options, callback = ->) ->
  randomCode = shortid()
  cacheKey = "smsverifycode:#{randomCode}"

  # 保存新的 verify code
  verifyCode = "#{Math.random()}"[2...6]
  data =
    verifyCode: verifyCode
    phoneNumber: options.phoneNumber
    createdAt: Date.now()
    password: options.password

  $verifyCode = redis.setexAsync cacheKey, 600, JSON.stringify data
  .then -> verifyCode
  $sendSMS = $verifyCode.then (verifyCode) ->
    msg = "您的手机验证码 #{verifyCode}，请在十分钟内使用，简聊/Talk"
    options.msg = msg
    util.sendSMS options

  Promise.all [$verifyCode, $sendSMS]
  .spread (verifyCode) ->
    callback null,
      randomCode: randomCode
      verifyCode: verifyCode

  .catch callback

MobileSchema.statics.verify = (randomCode, verifyCode, callback) ->
  cacheKey = "smsverifycode:#{randomCode}"

  redis.get cacheKey, (err, data) ->
    try
      verifyData = JSON.parse data
    catch err

    verifyData or= {}

    if verifyData.verifyCode?.length and verifyData.verifyCode is verifyCode and
       verifyData.phoneNumber?.length
      # 手机号存在且验证码正确
      redis.del cacheKey
      return callback null, verifyData

    callback(new Err('VERIFY_FAILED'))
