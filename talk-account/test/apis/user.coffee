should = require 'should'
config = require 'config'
Promise = require 'bluebird'
util = require '../util'

limbo = require 'limbo'
{
  UserModel
  MobileModel
} = limbo.use 'account'

_createUser = (done) ->
  phoneNumber = '18500000000'
  user = new UserModel
  mobile = new MobileModel
    user: user._id
    phoneNumber: phoneNumber
  Promise.all [user.$save(), mobile.$save()]
  .spread (user, mobile) ->
    user.accountToken = user.genAccountToken login: 'mobile'
    util.user = user
    util.mobile = mobile
    done()
  .catch done

describe 'User', ->

  before _createUser

  it 'should read user infomation by account token', (done) ->
    options =
      method: 'GET'
      url: '/user/get'
      qs: accountToken: util.user.accountToken
    util.request options, (err, res, user) ->
      user._id.should.eql "#{util.user._id}"
      user.should.have.properties 'phoneNumber', 'login', 'wasNew'
      done err

  it 'should read all bind accounts of current user', (done) ->
    # 绑定 Teambition 账号
    $bindUnion = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/union/bind/teambition'
        body:
          accountToken: util.user.accountToken
          code: 'xxx'
      util.requestAsync options

    $bindUnion.then ->
      options =
        method: 'GET'
        url: '/user/accounts'
        qs: accountToken: util.user.accountToken
      util.requestAsync options

    .spread (res, accounts) ->
      accounts.length.should.eql 2
      accounts[0].login.should.eql 'mobile'
      accounts[0].should.have.properties 'phoneNumber'
      accounts[1].login.should.eql 'teambition'
      accounts[1].should.have.properties 'openId', 'refer'
      done()

    .catch done

  after util.cleanup
