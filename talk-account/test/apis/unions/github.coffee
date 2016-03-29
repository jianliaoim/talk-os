should = require 'should'
request = require 'supertest'
jwt = require 'jsonwebtoken'
app = require '../../../server/server'
util = require '../../util'

describe 'Union#Github', ->

  before util.prepare

  it 'should redirect to github account page when visit redirect url', (done) ->
    request(app).get '/union/github'
    .end (err, res) ->
      res.statusCode.should.eql 302
      location = res.headers.location
      location.should.eql 'http://127.0.0.1:7632/gb/account/oauth/authorize?client_id=c98677c124ddeaa52cd5&redirect_uri=http%3A%2F%2Faccount.talk.bi%2Funion%2Fcallback%2Fgithub&scope=user%2Crepo%2Cgist'
      done()

  it 'should create new account with a grant code from github account api', (done) ->
    options =
      method: 'POST'
      url: '/union/signin/github'
      body: code: 'XXX'
    util.request options, (err, res, user) ->
      user.should.have.properties 'name', 'refer', 'openId', 'accountToken', 'wasNew', 'showname'
      user.wasNew.should.eql true
      user.name.should.eql 'github 用户'
      user.showname.should.eql '简聊'
      user.openId.should.eql '1111111'
      {id, login} = jwt.decode user.accountToken
      login.should.eql 'github'
      util.user = user
      done err

  it 'should not bind to an exist github account', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/github'
      body:
        accountToken: util.user.accountToken
        code: 'XXX'
    util.request options, (err, res, body) ->
      err.message.should.eql '绑定账号已存在'
      err.data.should.have.properties 'bindCode'
      util.bindCode = err.data.bindCode
      done()

  it 'should bind to an exist github account by bindCode', (done) ->
    options =
      method: 'POST'
      url: '/union/forcebind/github'
      body:
        accountToken: util.user.accountToken
        bindCode: util.bindCode
    util.request options, (err, res, user) ->
      user.should.have.properties 'accountToken', 'refer', 'openId'
      done err

  it 'should unbind github account', (done) ->
    options =
      method: 'POST'
      url: '/union/unbind/github'
      body:
        accountToken: util.user.accountToken
    util.request options, (err, res, user) ->
      user.should.not.have.properties 'refer', 'openId'
      done err

  it 'should bind github account again', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/github'
      body:
        accountToken: util.user.accountToken
        code: 'xxx'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  it 'should change the github account', (done) ->
    options =
      method: 'POST'
      url: '/union/change/github'
      body:
        accountToken: util.user.accountToken
        code: 'xxx'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  after util.cleanup
