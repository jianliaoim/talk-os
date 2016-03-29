should = require 'should'
config = require 'config'

jwt = require 'jsonwebtoken'
Promise = require 'bluebird'
util = require '../util'
appUtil = require '../../server/util'
redis = require '../../server/components/redis'

emailAddress = 'lurenjia@teambition.com'

describe 'Email', ->

  before util.prepare

  it 'should create an email account', (done) ->

    options =
      method: 'POST'
      url: '/email/signup'
      body:
        emailAddress: emailAddress
        password: '123456'

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'emailAddress', 'accountToken', 'wasNew'
      user.should.not.have.properties 'password'
      user.wasNew.should.eql true
      util.user1 = user

    .nodeify done

  it 'should login with email and password', (done) ->

    options =
      method: 'POST'
      url: '/email/signin'
      body:
        emailAddress: emailAddress
        password: '123456'

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'emailAddress', 'accountToken', 'wasNew'
      user.should.not.have.properties 'password'
      user.emailAddress.should.eql util.user1.emailAddress
      user.wasNew.should.eql false

    .nodeify done

  it 'should not bind to an exist email', (done) ->
    $verifyData = redis.delAsync "sentverify:#{emailAddress}"
    .then ->
      options =
        method: 'POST'
        url: '/email/sendverifycode'
        body:
          emailAddress: emailAddress
          action: 'bind'
      util.requestAsync options
    .spread (res, body) -> body

    $bind = $verifyData.then (verifyData) ->
      options =
        method: 'POST'
        url: '/email/bind'
        body:
          verifyCode: verifyData.verifyCode
          randomCode: verifyData.randomCode
          accountToken: util.user1.accountToken
      util.requestAsync options

    .spread (res, body) -> done new Error('无法绑定已存在的邮箱')

    .catch (err) ->
      err.message.should.eql '绑定账号已存在'
      err.should.have.properties 'data'
      err.data.should.have.properties 'bindCode', 'showname'
      util.bindCode = err.data.bindCode
      done()

  it 'should bind to then existing email address by bindCode', (done) ->
    options =
      method: 'POST'
      url: '/email/forcebind'
      body:
        bindCode: util.bindCode
        accountToken: util.user1.accountToken
    util.request options, (err, res, user) ->
      user.should.have.properties 'emailAddress', 'accountToken', 'login'
      user.emailAddress.should.eql emailAddress
      done err

  it 'should unbind then current email address', (done) ->
    options =
      method: 'POST'
      url: '/email/unbind'
      body:
        accountToken: util.user1.accountToken
        emailAddress: emailAddress
    util.request options, (err, res, user) ->
      user.should.not.have.properties 'emailAddress', 'accountToken', 'login'
      done err

  it 'should bind to another email address', (done) ->
    emailAddress2 = 'lurenyi@jianliao.com'

    $verifyData = redis.delAsync "sentverify:#{emailAddress2}"
    .then ->
      options =
        method: 'POST'
        url: '/email/sendverifycode'
        body:
          emailAddress: emailAddress2
          action: 'bind'
      util.requestAsync options
    .spread (res, body) -> body

    $bind = $verifyData.then (verifyData) ->
      options =
        method: 'POST'
        url: '/email/bind'
        body:
          accountToken: util.user1.accountToken
          randomCode: verifyData.randomCode
          verifyCode: verifyData.verifyCode
      util.requestAsync options

    .spread (res, user) ->
      user.should.have.properties 'emailAddress', 'accountToken'
      user.emailAddress.should.eql emailAddress2
      done()

    .catch done

  it 'should change the emailAddress through change api', (done) ->
    $verifyData = redis.delAsync "sentverify:#{emailAddress}"
    .then ->
      options =
        method: 'POST'
        url: '/email/sendverifycode'
        body:
          emailAddress: emailAddress
          action: 'change'
      util.requestAsync options
    .spread (res, body) -> body

    $change = $verifyData.then (verifyData) ->
      options =
        method: 'POST'
        url: '/email/change'
        body:
          accountToken: util.user1.accountToken
          randomCode: verifyData.randomCode
          verifyCode: verifyData.verifyCode
      util.requestAsync options

    .spread (res, user) ->
      user.should.have.properties 'emailAddress', 'accountToken'
      user.emailAddress.should.eql emailAddress
      done()

    .catch done

  after util.cleanup

describe 'Email#ResetPassword', ->

  before util.prepare

  it 'should send verify code and get random code', (done) ->
    $createEmail = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/email/signup'
        body:
          emailAddress: emailAddress
          password: '123456'
      util.requestAsync options

    $sendVerifyCode = $createEmail.then ->
      options =
        method: 'POST'
        url: '/email/sendverifycode'
        body:
          emailAddress : emailAddress
          action: 'resetpassword'

      util.requestAsync options

    .spread (res, body) ->
      body.should.have.properties 'randomCode'
      util.randomCode = body.randomCode
      util.verifyCode = body.verifyCode

    $checkVerifyEmail = new Promise (resolve, reject) ->
      util.checkEmail = (email) ->
        try
          email.html.should.containEql '/reset-password?resetToken='
        catch err
          return reject err
        emailData = email.html.match /resettoken\=(.+?)\"/i
        util.resetToken = decodeURIComponent emailData[1]
        resolve()

    $checkResetToken = Promise.all [$sendVerifyCode, $checkVerifyEmail]

    .then ->
      appUtil.parseVerifyTokenAsync util.resetToken

      .then (verifyData) ->
        verifyData.randomCode.should.eql util.randomCode
        verifyData.verifyCode.should.eql util.verifyCode

    Promise.all [$sendVerifyCode, $checkVerifyEmail, $checkResetToken]

    .nodeify done

  it 'should check reset password request verify code and auto login', (done) ->
    options =
      method: 'POST'
      url: '/email/signinbyverifycode'
      body:
        randomCode: util.randomCode
        verifyCode: util.verifyCode

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'emailAddress', 'accountToken', 'wasNew'
      user.should.not.have.properties 'password'
      user.emailAddress.should.eql emailAddress
      user.wasNew.should.eql false
      util.user1 = user

    .nodeify done

  it 'should change to new password', (done) ->
    options =
      method: 'POST'
      url: '/email/resetpassword'
      body:
        newPassword: 'abc123456'
        accountToken: util.user1.accountToken

    util.requestAsync options
    .spread (res, user) ->
      user.wasNew.should.eql false
      user.should.have.properties 'accountToken'
    .nodeify done

  it 'should login with email and new password', (done) ->

    options =
      method: 'POST'
      url: '/email/signin'
      body:
        emailAddress: emailAddress
        password: 'abc123456'

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'emailAddress', 'accountToken', 'wasNew'
      user.should.not.have.properties 'password'
      user.emailAddress.should.eql util.user1.emailAddress
      user.wasNew.should.eql false
      done()

    .catch done

  after util.cleanup
