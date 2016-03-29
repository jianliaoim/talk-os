###*
 * 手机验证码登录/注册接口
###

Err = require 'err1st'
limbo = require 'limbo'
config = require 'config'
Promise = require 'bluebird'
_ = require 'lodash'

app = require '../server'
util = require '../util'
redis = require '../components/redis'

{
  MobileModel
  UserModel
} = limbo.use 'account'

module.exports = mobileController = app.controller 'mobile', ->

  @mixin require './mixins/auth'
  @mixin require './mixins/cookie'

  @ratelimit '6,60 15,300', only: 'sendVerifyCode' unless config.debug
  @ratelimit '20,60 80,300', only: 'bind signin change'

  @ensure 'phoneNumber', only: 'sendVerifyCode unbind'
  @ensure 'randomCode verifyCode', only: 'bind change signup'
  @ensure 'newPassword', only: 'resetPassword'
  @ensure 'bindCode', only: 'forcebind'

  @before 'delay1s', only: 'signin signup bind change' unless config.debug
  @before 'verifyAccount', only: 'bind unbind forcebind change resetPassword'

  @after 'mobileToUser', only: 'signin signup bind forcebind change signinByVerifyCode'
  @after 'setAccountToken', only: 'signin signup bind forcebind unbind change signinByVerifyCode resetPassword'
  @after 'setCookie', only: 'signin signup bind forcebind unbind change signinByVerifyCode'

################################# ACTIONS #################################
  ###*
   * 发送手机验证码，同一号码 30 秒内只可发送一次，有效期 10 分钟
   * @return {Object} ok: 1
  ###
  @action 'sendVerifyCode', (req, res, callback) ->
    {phoneNumber, password, action, uid} = req.get()
    sentVerifyKey = "sentverify:#{phoneNumber}"

    switch action

      when 'signup'
        # 如果是注册操作，验证手机号是否存在，验证是否有 password 参数
        if password?.length
          $check = MobileModel.findOneAsync phoneNumber: phoneNumber
          .then (mobile) -> throw new Err('ACCOUNT_EXISTS') if mobile
        else
          $check = Promise.reject(new Err('PARAMS_MISSING', 'password'))

      when 'resetpassword'
        # 如果是重置密码操作，先确认手机号存在
        $check = MobileModel.findOneAsync phoneNumber: phoneNumber
        .then (mobile) -> throw new Err('ACCOUNT_NOT_EXIST') unless mobile

      # @todo Remove
      else $check = Promise.resolve()

    $sent = $check.then -> redis.getAsync sentVerifyKey

    .then (sent) ->
      throw new Err('RESEND_TOO_OFTEN') if sent and not process.env.DEBUG

      options =
        phoneNumber: phoneNumber
        ip: req.headers['x-real-ip'] or req.ip
        _userId: 'new'
        password: password
        uid: uid

      switch action
        when 'signup' then options.refer = 'jianliao_register'
        when 'resetpassword' then options.refer = 'jianliao_resetpassword'
        else options.refer = 'jianliao_register'

      $verifyData = MobileModel.sendVerifyCodeAsync options

      $setSentFlag = $verifyData.then -> redis.setexAsync sentVerifyKey, 60, 1

      Promise.all [$verifyData, $setSentFlag]

      .spread (verifyData) -> verifyData

    .then (verifyData) ->

      if config.debug
        data = _.pick(verifyData, 'randomCode', 'verifyCode')
      else
        data = _.pick(verifyData, 'randomCode')

    .nodeify callback

  ###*
   * 验证手机号并返回账号信息，如果手机号已存在，则返回原账号信息
   * @return {Model} user - 用户信息
  ###
  @action 'signin', (req, res, callback) ->
    {phoneNumber, password, randomCode, verifyCode} = req.get()

    if phoneNumber and password
      return @signinByPassword req, res, callback

    if randomCode and verifyCode
      return @signinByVerifyCode req, res, callback

    callback(new Err('PARAMS_MISSING', 'phoneNumber, password'))

  ###*
   * 手机注册
  ###
  @action 'signup', (req, res, callback) ->
    {phoneNumber, randomCode, verifyCode} = req.get()

    # 读取验证码
    $verifyData = MobileModel.verifyAsync randomCode, verifyCode

    .then (verifyData) ->
      throw new Err('PARAMS_MISSING', 'password') unless verifyData.password
      verifyData

    # 检测手机号是否存在
    $mobileNotExists = $verifyData.then (verifyData) ->
      MobileModel.findOneAsync phoneNumber: verifyData.phoneNumber

    .then (mobile) -> throw new Err('ACCOUNT_EXISTS') if mobile

    # 创建手机号与用户账号
    $mobile = Promise.all [$verifyData, $mobileNotExists]

    .spread (verifyData) ->
      # 创建新用户
      user = new UserModel
      user.password = user.genPassword verifyData.password

      mobile = new MobileModel
        phoneNumber: verifyData.phoneNumber
        user: user

      Promise.all [user.$save(), mobile.$save()]

      .spread (user, mobile) -> mobile

    # 返回结果
    $mobile.nodeify callback

  @action 'bind', (req, res, callback) ->
    {user, verifyCode, randomCode} = req.get()

    $phoneNumber = MobileModel.verifyAsync randomCode, verifyCode

    .then (verifyData) -> verifyData.phoneNumber

    $mobile = $phoneNumber.then (phoneNumber) ->
      MobileModel.findOne phoneNumber: phoneNumber
      .execAsync()
      .then (mobile) ->
        if mobile?.user
          # 生成 bindCode 并返回错误信息
          return $bindCode = mobile.genBindCodeAsync().then (bindCode) ->
            err = new Err('BIND_CONFLICT')
            err.data =
              bindCode: bindCode
              showname: phoneNumber
            throw err
        if mobile
          mobile.user = user
        else
          mobile = new MobileModel
            phoneNumber: phoneNumber
            user: user
        mobile.updatedAt = new Date
        mobile

    $cleanupOtherMobiles = $mobile.then (mobile) ->
      MobileModel.removeAsync
        user: user._id
        phoneNumber: $ne: mobile.phoneNumber

    $mobile = Promise.all [$mobile, $cleanupOtherMobiles]
    .spread (mobile) -> mobile.$save()

    $mobile.nodeify callback

  @action 'change', (req, res, callback) ->
    @bind req, res, callback

  @action 'forcebind', (req, res, callback) ->
    {user, bindCode} = req.get()

    $mobile = MobileModel.verifyBindCodeAsync bindCode

    $mobile = $mobile.then (mobile) ->
      mobile.user = user
      mobile.updatedAt = new Date
      mobile.$save()

    $cleanupOtherMobiles = $mobile.then (mobile) ->
      MobileModel.removeAsync
        user: user._id
        phoneNumber: $ne: mobile.phoneNumber

    Promise.all [$mobile, $cleanupOtherMobiles]
    .spread (mobile) -> mobile
    .nodeify callback

  @action 'unbind', (req, res, callback) ->
    {user, phoneNumber} = req.get()

    $mobile = MobileModel.findOneAsync
      user: user._id
      phoneNumber: phoneNumber
    .then (mobile) ->
      if mobile?.user
        mobile.$remove()

    $user = $mobile.then -> user
    .nodeify callback

  @action 'signinByPassword', (req, res, callback) ->
    {phoneNumber, password} = req.get()

    $mobile = MobileModel.findOne phoneNumber: phoneNumber

    .populate 'user'

    .execAsync()

    .then (mobile) ->

      throw new Err('LOGIN_VERIFY_FAILED') unless mobile?.user

      throw new Err('NO_PASSWORD') unless mobile?.user?.password

      mobile.user.verifyPasswordAsync password

      .then -> mobile

    $mobile.nodeify callback

  @action 'signinByVerifyCode', (req, res, callback) ->
    {verifyCode, randomCode, action} = req.get()

    $phoneNumber = MobileModel.verifyAsync randomCode, verifyCode
    .then (verifyData) -> verifyData.phoneNumber

    $mobile = $phoneNumber.then (phoneNumber) ->
      # 根据手机号查找老用户
      MobileModel.findOne phoneNumber: phoneNumber
      .populate 'user'
      .execAsync()
      .then (mobile) ->
        return mobile if mobile?.user
        if action is 'resetpassword'
          throw new Err('ACCOUNT_NOT_EXIST')
        else
          # 针对老版本通过手机验证码就可以进行账号的创建
          user = new UserModel
          unless mobile
            mobile = new MobileModel
          mobile.user = user
          mobile.phoneNumber = phoneNumber
          Promise.all [user.$save(), mobile.$save()]
          .spread (user, mobile) -> mobile

    .nodeify callback

  @action 'resetPassword', (req, res, callback) ->
    {user, newPassword} = req.get()
    user.password = user.genPassword newPassword
    $user = user.$save()
    $user.nodeify callback

################################# HOOKS #################################
#
  @action 'mobileToUser', (req, res, mobile, callback) ->
    {user} = mobile
    return callback(new Err('LOGIN_FAILED', '未成功绑定用户账号')) unless user
    user.phoneNumber = mobile.phoneNumber
    user.showname = mobile.showname
    callback null, user

  @action 'setAccountToken', (req, res, user, callback) ->
    user.accountToken = user.genAccountToken login: 'mobile'
    callback null, user
