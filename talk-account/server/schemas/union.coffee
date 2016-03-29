###*
 * 第三方登录账号记录表
 * db.unions.ensureIndex({refer: 1, openId: 1}, {unique: true, background: true})
 * db.unions.ensureIndex({user: 1}, {background: true})
###
{Schema} = require 'mongoose'
Promise = require 'bluebird'
Err = require 'err1st'
shortid = require 'shortid'
redis = require '../components/redis'

module.exports = UnionSchema = new Schema
  refer: type: String  # 来源网站
  openId: type: String
  name: type: String
  showname: type: String, get: (showname) -> showname or @name or "第三方账号"
  avatarUrl: type: String
  accessToken: type: String
  refreshToken: type: String
  refreshAt: type: Date
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

UnionSchema.virtual 'login'
  .get -> @refer

###*
 * 生成绑定信息随机码
 * @return {String} bindCode
###
UnionSchema.methods.genBindCode = (showname, callback) ->
  bindCode = shortid()
  cacheKey = "unionbindcode:#{bindCode}"
  data =
    _id: @_id
    showname: showname
  redis.setex cacheKey, 600, JSON.stringify(data), (err) ->
    callback err, bindCode

############################ STATICS ############################

###*
 * 获取绑定信息随机码
 * @return {String} showname 账号名称
###
UnionSchema.statics.getBindData = (bindCode, callback) ->
  cacheKey = "unionbindcode:#{bindCode}"

  redis.get cacheKey, (err, data) ->
    try
      {showname} = JSON.parse data
    catch err

    if showname?.length
      return callback null,
        showname: showname
    else
      return callback(new Err('OBJECT_MISSING', 'showname'))

UnionSchema.statics.verifyBindCode = (bindCode, callback) ->
  cacheKey = "unionbindcode:#{bindCode}"
  UnionModel = this
  redis.get cacheKey, (err, data) ->
    try
      {_id} = JSON.parse data
    catch err
    return callback(new Err("VERIFY_FAILED")) unless _id
    UnionModel.findOne _id: _id, (err, union) ->
      return callback(new Err('OBJECT_MISSING', 'union')) unless union
      redis.del cacheKey
      callback err, union
