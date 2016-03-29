should = require 'should'
config = require 'config'
jwt = require 'jsonwebtoken'
Promise = require 'bluebird'
limbo = require 'limbo'

util = require '../util'
redis = require '../../server/components/redis'

phoneNumber = '18500000000'

{
  MobileModel
  UserModel
} = limbo.use 'account'

requestUtil = require '../../server/util/request'
requestUtil.sendSMS = -> Promise.resolve({})

describe 'Mobile', ->

  before util.prepare

  it 'should send verify code and get random code', (done) ->

    options =
      method: 'POST'
      url: '/mobile/sendverifycode'
      body: phoneNumber: phoneNumber
    util.request options, (err, res, body) ->
      body.should.have.properties 'randomCode'
      util.randomCode = body.randomCode
      util.verifyCode = body.verifyCode
      done err

  it 'should create a new user after verifing phone number', (done) ->
    options =
      method: 'POST'
      url: '/mobile/signin'
      body:
        verifyCode: util.verifyCode
        randomCode: util.randomCode

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'phoneNumber', 'accountToken', 'wasNew'
      user.phoneNumber.should.eql phoneNumber
      user.wasNew.should.eql true
      {_id, login} = jwt.decode user.accountToken
      login.should.eql 'mobile'
      util.user1 = user
      done()

    .catch done

  it 'should not bind to an exist phone number', (done) ->
    $verifyData = redis.delAsync "sentverify:#{phoneNumber}"
    .then ->
      options =
        method: 'POST'
        url: '/mobile/sendverifycode'
        body: phoneNumber: phoneNumber
      util.requestAsync options
    .spread (res, body) -> body

    $bind = $verifyData.then (verifyData) ->
      options =
        method: 'POST'
        url: '/mobile/bind'
        body:
          accountToken: util.user1.accountToken
          randomCode: verifyData.randomCode
          verifyCode: verifyData.verifyCode
      util.requestAsync options

    .spread (res, body) -> done new Error('无法绑定已存在的手机号')

    .catch (err) ->
      err.message.should.eql '绑定账号已存在'
      err.should.have.properties 'data'
      err.data.should.have.properties 'bindCode', 'showname'
      util.bindCode = err.data.bindCode
      done()

  it 'should bind to the exist phone number by bindCode', (done) ->
    options =
      method: 'POST'
      url: '/mobile/forcebind'
      body:
        bindCode: util.bindCode
        accountToken: util.user1.accountToken
    util.request options, (err, res, user) ->
      user.should.have.properties 'phoneNumber', 'accountToken', 'login'
      user.phoneNumber.should.eql phoneNumber
      done err

  it 'should unbind the current phone number', (done) ->
    options =
      method: 'POST'
      url: '/mobile/unbind'
      body:
        accountToken: util.user1.accountToken
        phoneNumber: phoneNumber
    util.request options, (err, res, user) ->
      user.should.not.have.properties 'phoneNumber', 'accountToken', 'login'
      done err

  it 'should bind to another phone number', (done) ->
    phoneNumber2 = '18500000001'

    $verifyData = redis.delAsync "sentverify:#{phoneNumber2}"

    .then ->
      options =
        method: 'POST'
        url: '/mobile/sendverifycode'
        body: phoneNumber: phoneNumber2
      util.requestAsync options

    .spread (res, body) -> body

    $bind = $verifyData

    .then (verifyData) ->
      options =
        method: 'POST'
        url: '/mobile/bind'
        body:
          accountToken: util.user1.accountToken
          randomCode: verifyData.randomCode
          verifyCode: verifyData.verifyCode
      util.requestAsync options

    .spread (res, user) ->
      user.should.have.properties 'phoneNumber', 'accountToken'
      user.phoneNumber.should.eql phoneNumber2
      done()

    .catch done

  it 'should change the phoneNumber through change api', (done) ->
    $verifyData = redis.delAsync "sentverify:#{phoneNumber}"

    .then ->
      options =
        method: 'POST'
        url: '/mobile/sendverifycode'
        body: phoneNumber: phoneNumber
      util.requestAsync options

    .spread (res, body) -> body

    $change = $verifyData.then (verifyData) ->
      options =
        method: 'POST'
        url: '/mobile/change'
        body:
          accountToken: util.user1.accountToken
          randomCode: verifyData.randomCode
          verifyCode: verifyData.verifyCode
      util.requestAsync options

    .spread (res, user) ->
      user.should.have.properties 'phoneNumber', 'accountToken'
      user.phoneNumber.should.eql phoneNumber
      done()

    .catch done

  after util.cleanup

describe 'Mobile#WithPassword', ->

  before util.prepare

  it 'should send verifycode with password', (done) ->

    options =
      method: 'POST'
      url: '/mobile/sendverifycode'
      body:
        action: 'signup'
        phoneNumber: phoneNumber
        password: '123456'

    util.requestAsync options

    .spread (res, body) ->
      body.should.have.properties 'randomCode'
      util.randomCode = body.randomCode
      util.verifyCode = body.verifyCode

    .nodeify done

  it 'should signup by verifyCode with password', (done) ->

    options =
      method: 'POST'
      url: '/mobile/signup'
      body:
        phoneNumber: phoneNumber
        randomCode: util.randomCode
        verifyCode: util.verifyCode

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'phoneNumber', 'accountToken', 'wasNew'
      user.phoneNumber.should.eql phoneNumber
      user.wasNew.should.eql true

    .nodeify done

  it 'should signin by phoneNumber and password', (done) ->

    options =
      method: 'POST'
      url: '/mobile/signin'
      body:
        phoneNumber: phoneNumber
        password: '123456'

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'phoneNumber', 'accountToken', 'wasNew'
      user.phoneNumber.should.eql phoneNumber
      user.wasNew.should.eql false
      done()

    .catch done

  after util.cleanup

describe 'Mobile#checkResetPasswordVerifyCode', ->

  newPhoneNumber = '15700000000'

  before util.prepare

  it 'should send verifycode with password', (done) ->

    $createMobile = Promise.resolve().then ->
      user = new UserModel
      mobile = new MobileModel
        phoneNumber: newPhoneNumber
        user: user
      Promise.all [user.$save(), mobile.$save()]

    $sendVerifyCode = $createMobile.then ->
      options =
        method: 'POST'
        url: '/mobile/sendverifycode'
        body:
          action: 'resetpassword'
          phoneNumber: newPhoneNumber

      util.requestAsync options

    .spread (res, body) ->
      body.should.have.properties 'randomCode'
      util.randomCode = body.randomCode
      util.verifyCode = body.verifyCode
      done()

    .catch done

  it 'should check reset password request verify code and auto login', (done) ->

    $verify = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/mobile/signinbyverifycode'
        body:
          randomCode: util.randomCode
          verifyCode: util.verifyCode
          action: 'resetpassword'

      util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'phoneNumber', 'accountToken', 'wasNew'
      user.should.not.have.properties 'password'
      user.phoneNumber.should.eql newPhoneNumber
      user.wasNew.should.eql false
      util.user4 = user
      done()

    .catch done

  it 'should changed to the new password', (done) ->
    options =
      method: 'POST'
      url: '/mobile/resetpassword'
      body:
        newPassword: 'abc123456'
        accountToken: util.user4.accountToken

    util.requestAsync options

    .spread (res, user) ->
      user.wasNew.should.eql false
      user.should.have.properties 'accountToken'

    .nodeify done

  it 'should signin by phoneNumber and new password', (done) ->

    options =
      method: 'POST'
      url: '/mobile/signin'
      body:
        phoneNumber: newPhoneNumber
        password: 'abc123456'

    util.requestAsync options

    .spread (res, user) ->
      (res.headers['set-cookie'].some (str) -> str.indexOf('aid') isnt -1 ).should.eql true
      user.should.have.properties 'phoneNumber', 'accountToken', 'wasNew'
      user.phoneNumber.should.eql newPhoneNumber
      user.wasNew.should.eql false
      done()

    .catch done

  after util.cleanup
