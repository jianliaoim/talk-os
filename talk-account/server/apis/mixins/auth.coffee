Err = require 'err1st'
Promise = require 'bluebird'
limbo = require 'limbo'

{
  UserModel
  MobileModel
  EmailModel
  UnionModel
} = limbo.use 'account'

module.exports = authMixin =
  ###*
   * 验证 accountToken 并查找用户信息
   * @return {Model} user
  ###
  verifyAccount: (req, res, callback) ->
    if req.headers?.authorization and req.headers.authorization.indexOf('aid ') is 0
      [key, token] = req.headers.authorization.split ' '
      req.set 'accountToken', token
    UserModel.verifyAccountToken req.get('accountToken'), (err, user) ->
      req.set 'user', user
      callback err, user
  ###*
   * 根据登录方式添加详细信息
   * @return {Model} user
  ###
  appendUserDetail: (req, res, callback) ->
    {user} = req.get()
    $mobile = MobileModel.findOneAsync user: user._id
    $email = EmailModel.findOneAsync user: user._id
    $unions = UnionModel.findAsync user: user._id

    $user = Promise.all [$mobile, $email, $unions]

    .spread (mobile, email, unions) ->
      user.unions = unions if unions?.length > 0
      user.phoneNumber = mobile.phoneNumber if mobile?.phoneNumber
      user.emailAddress = email.emailAddress if email?.emailAddress
      user

    $user.then (user) ->
      req.set 'user', user
      callback null, user
    .catch callback

  ###*
   * 延迟 1 秒后返回结果
  ###
  delay1s: (req, res, callback) ->
    setTimeout ->
      callback()
    , 1000
