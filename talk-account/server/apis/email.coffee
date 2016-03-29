###*
 * 邮箱密码登录/注册接口
###

Err = require 'err1st'
limbo = require 'limbo'
config = require 'config'
Promise = require 'bluebird'
_ = require 'lodash'

app = require '../server'
util = require '../util'
redis = require '../components/redis'
mailer = require '../mailers'

{
  UserModel
  MobileModel
  UserModel
  EmailModel
} = limbo.use 'account'

module.exports = emailController = app.controller 'email', ->

  @mixin require './mixins/auth'
  @mixin require './mixins/cookie'

  @ratelimit '20,60 80,300', only: 'bind change signup signin'

  # Parse randomCode and verifyCode from verifyToken
  @before 'parseVerifyToken', only: 'bind change signinByVerifyCode'

  @ensure 'emailAddress', only: 'signup signin unbind'
  @ensure 'password', only: 'signup signin'
  @ensure 'randomCode verifyCode', only: 'bind change signinByVerifyCode'
  @ensure 'newPassword', only: 'resetPassword'
  @ensure 'bindCode', only: 'forcebind'

  @before 'delay1s', only: 'bind change signup signin' unless config.debug
  # Verify account and set the user model
  @before 'verifyAccount', only: 'bind change forcebind unbind resetPassword'

  @after 'emailToUser', only: 'bind change forcebind signinByVerifyCode'
  @after 'setAccountToken', only: 'bind change forcebind signup signin signinByVerifyCode resetPassword'
  @after 'setCookie', only: 'bind change forcebind signup signin signinByVerifyCode'

  @action 'signin', (req, res, callback) ->
    {emailAddress, password} = req.get()

    $email = EmailModel.findOne emailAddress: emailAddress

    .populate 'user'

    .execAsync()

    .then (email) ->

      throw new Err('LOGIN_VERIFY_FAILED') unless email?.user

      throw new Err('NO_PASSWORD') unless email?.user?.password

      email

    $user = $email.then (email) -> email.user.verifyPasswordAsync password

    Promise.all [$user, $email]

    .spread (user, email) ->
      user.emailAddress = email.emailAddress
      user

    .nodeify callback

  @action 'signup', (req, res, callback) ->
    {emailAddress, password} = req.get()

    # 检查账号是否存在
    $emailExists = EmailModel.findOneAsync emailAddress: emailAddress

    .then (email) -> throw new Err('ACCOUNT_EXISTS') if email

    # 创建新账号
    $user = $emailExists.then ->
      user = new UserModel
      user.password = user.genPassword password
      email = new EmailModel
        emailAddress: emailAddress
        user: user

      Promise.all [user.$save(), email.$save()]

      .spread (user, email) ->
        user.emailAddress = email.emailAddress
        user

    $user.nodeify callback

  @action 'sendVerifyCode', (req, res, callback) ->
    {emailAddress, action} = req.get()
    sentVerifyKey = "sentverify:#{emailAddress}"

    switch action

      when 'resetpassword'
        # 需要先判断邮箱存在才能够继续下面的找回密码操作
        $check = EmailModel.findOneAsync emailAddress: emailAddress
        .then (email) -> throw new Err('ACCOUNT_NOT_EXIST') unless email

      when 'bind', 'change'
        # Do not check existing email when bind/change email
        $check = Promise.resolve()

      else
        $check = Promise.reject(new Err('INVALID_ACTION'))

    # 检查是否频繁发送
    $verifyData = $check.then -> redis.getAsync sentVerifyKey

    # 保存验证码和邮箱信息到 redis
    .then (sent) ->
      throw new Err('RESEND_TOO_OFTEN') if sent and not process.env.DEBUG

      options = emailAddress: emailAddress

      $verifyData = EmailModel.saveVerifyCodeAsync options

    # 根据不同的 action 发送特定邮件模板
    $sendEmail = $verifyData.then (verifyData) ->

      switch action
        when 'resetpassword'
          resetMailer = mailer.getMailer 'reset-password'
          $sent = resetMailer.send verifyData, emailAddress
        when 'bind', 'change'
          verifyMailer = mailer.getMailer 'verify'
          verifyData.action = action
          $sent = verifyMailer.send verifyData, emailAddress
        else
          $sent = Promise.reject(new Err('INVALID_ACTION'))

      $sent

    # 设置已发送标识
    $setSentFlag = $sendEmail.then -> redis.setexAsync sentVerifyKey, 60, 1

    # 返回响应结果到客户端
    Promise.all [$verifyData, $sendEmail, $setSentFlag]

    .spread (verifyData) ->

      if config.debug
        data = _.pick(verifyData, 'randomCode', 'verifyCode')
      else
        data = _.pick(verifyData, 'randomCode')

    .nodeify callback

  # 验证邮箱验证码同时登录
  @action 'signinByVerifyCode', (req, res, callback) ->
    {verifyCode, randomCode} = req.get()

    $emailAddress = EmailModel.verifyAsync randomCode, verifyCode
    .then (verifyData) -> verifyData.emailAddress

    $email = $emailAddress.then (emailAddress) ->
      # 根据邮箱查找老用户
      EmailModel.findOne emailAddress: emailAddress
      .populate 'user'
      .execAsync()
      .then (email) ->
        return email if email.user
        throw new Err('ACCOUNT_NOT_EXIST')

    .nodeify callback

  @action 'resetPassword', (req, res, callback) ->
    {user, newPassword} = req.get()
    user.password = user.genPassword newPassword

    $user = user.$save()
    $user.nodeify callback

  @action 'bind', (req, res, callback) ->
    {user, randomCode, verifyCode} = req.get()
    $emailAddress = EmailModel.verifyAsync randomCode, verifyCode
    .then (verifyData) -> verifyData.emailAddress

    $email = $emailAddress.then (emailAddress) ->
      EmailModel.findOne emailAddress: emailAddress
      .populate 'user'
      .execAsync()
      .then (email) ->
        if email?.user
          return $bindCode = email.genBindCodeAsync().then (bindCode) ->
            err = new Err('BIND_CONFLICT')
            err.data =
              bindCode: bindCode
              showname: emailAddress
            throw err
        else if email
          email.user = user
        else
          email = new EmailModel
            emailAddress: emailAddress
            user: user
        email.updatedAt = new Date
        email

    $cleanupOtherEmails = $email.then (email) ->
      EmailModel.removeAsync
        user: user._id
        emailAddress: $ne: email.emailAddress

    $email = Promise.all [$email, $cleanupOtherEmails]
    .spread (email) -> email.$save()

    $email.nodeify callback

  @action 'forcebind', (req, res, callback) ->
    {user, bindCode} = req.get()
    $email = EmailModel.verifyBindCodeAsync bindCode

    $email = $email.then (email) ->
      email.user = user
      email.updatedAt = new Date
      email.$save()

    $cleanupOtherEmails = $email.then (email) ->
      EmailModel.removeAsync
        user: user._id
        emailAddress: $ne: email.emailAddress

    Promise.all [$email, $cleanupOtherEmails]
    .spread (email) -> email
    .nodeify callback

  @action 'change', (req, res, callback) ->
    @bind req, res, callback

  @action 'unbind', (req, res, callback) ->
    {user, emailAddress} = req.get()

    $email = EmailModel.findOneAsync
      user: user._id
      emailAddress: emailAddress
    .then (email) ->
      if email?.user
        email.$remove()

    $email.then -> user
    .nodeify callback

  @action 'preview', (req, res, callback) ->
    {template} = req.query
    return res.end('Empty template name') unless template

    html = mailer.getMailer(template).preview (err, html) ->
      if err
        return res.status(400).end err.stack
      res.status(200).send html
################################# HOOKS #################################

  @action 'setAccountToken', (req, res, user, callback) ->
    user.accountToken = user.genAccountToken login: 'email'
    callback null, user

  @action 'emailToUser', (req, res, email, callback) ->
    {user} = email
    return callback(new Err('LOGIN_FAILED', '未成功绑定用户账号')) unless user
    user.emailAddress = email.emailAddress
    callback null, user

  # Set randomCode and verifyCode from verifyToken
  @action 'parseVerifyToken', (req, res, callback) ->
    {verifyToken} = req.get()
    return callback() unless verifyToken?.length
    util.parseVerifyToken verifyToken, (err, verifyData = {}) ->
      req.set 'randomCode', verifyData.randomCode
      req.set 'verifyCode', verifyData.verifyCode
      callback err
