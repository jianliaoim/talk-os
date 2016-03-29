should = require 'should'
request = require 'supertest'
jwt = require 'jsonwebtoken'
app = require '../../../server/server'
util = require '../../util'

describe 'Union#Teambition', ->

  before util.prepare

  it 'should redirect to teambition account page when visit redirect url', (done) ->
    request(app).get '/union/teambition'
    .end (err, res) ->
      res.statusCode.should.eql 302
      location = res.headers.location
      location.should.eql 'http://127.0.0.1:7632/tb/account/oauth2/authorize?client_id=1b3356c0-5149-11e5-ae15-2db6ab967d11&redirect_uri=http%3A%2F%2Faccount.talk.bi%2Funion%2Fcallback%2Fteambition&enforce_login=1'
      done()

  it 'should create new account with a grant code from teambition account api', (done) ->
    options =
      method: 'POST'
      url: '/union/signin/teambition'
      body: code: 'XXX'
    util.request options, (err, res, user) ->
      user.should.have.properties 'name', 'refer', 'openId', 'accountToken', 'wasNew', 'showname'
      user.wasNew.should.eql true
      user.name.should.eql 'teambition 用户'
      user.showname.should.eql 'jianliao@teambition.com'
      user.openId.should.eql '55ed1e3aaa6373be1e9fd60a'
      {_id, login} = jwt.decode user.accountToken
      login.should.eql 'teambition'
      util.user = user
      done err

  it 'should not bind to an exist teambition account', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/teambition'
      body:
        accountToken: util.user.accountToken
        code: 'XXX'
    util.request options, (err, res, body) ->
      err.message.should.eql '绑定账号已存在'
      err.data.should.have.properties 'bindCode'
      util.bindCode = err.data.bindCode
      done()

  it 'should bind to an exist teambition account by bindCode', (done) ->
    options =
      method: 'POST'
      url: '/union/forcebind/teambition'
      body:
        accountToken: util.user.accountToken
        bindCode: util.bindCode
    util.request options, (err, res, user) ->
      user.should.have.properties 'accountToken', 'refer', 'openId'
      done err

  it 'should unbind teambition account', (done) ->
    options =
      method: 'POST'
      url: '/union/unbind/teambition'
      body:
        accountToken: util.user.accountToken
    util.request options, (err, res, user) ->
      user.should.not.have.properties 'refer', 'openId'
      done err

  it 'should bind teambition account again', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/teambition'
      body:
        accountToken: util.user.accountToken
        code: 'xxx'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  it 'should change the teambition account', (done) ->
    options =
      method: 'POST'
      url: '/union/change/teambition'
      body:
        accountToken: util.user.accountToken
        code: 'xxx'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  after util.cleanup
