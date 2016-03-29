should = require 'should'
request = require 'supertest'
jwt = require 'jsonwebtoken'
app = require '../../../server/server'
util = require '../../util'

describe 'Union#Weibo', ->

  before util.prepare

  it 'should redirect to weibo account page when visit redirect url', (done) ->
    request(app).get '/union/weibo'
    .end (err, res) ->
      res.statusCode.should.eql 302
      location = res.headers.location
      location.should.eql 'http://127.0.0.1:7632/wb/account/oauth2/authorize?client_id=2594699207&redirect_uri=http%3A%2F%2Faccount.talk.bi%2Funion%2Fcallback%2Fweibo&forcelogin=true&scope=all'
      done()

  it 'should create new account with a grant code from weibo account api', (done) ->
    options =
      method: 'POST'
      url: '/union/signin/weibo'
      body: code: 'XXX'
    util.request options, (err, res, user) ->
      user.should.have.properties 'name', 'refer', 'openId', 'accountToken', 'wasNew', 'showname'
      user.wasNew.should.eql true
      user.name.should.eql '微博用户'
      user.openId.should.eql '1234567890'
      user.showname.should.eql '简聊'
      {id, login} = jwt.decode user.accountToken
      login.should.eql 'weibo'
      util.user = user
      done err

  it 'should not bind to an exist weibo account', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/weibo'
      body:
        accountToken: util.user.accountToken
        code: 'XXX'
    util.request options, (err, res, body) ->
      err.message.should.eql '绑定账号已存在'
      err.data.should.have.properties 'bindCode'
      util.bindCode = err.data.bindCode
      done()

  it 'should bind to an exist weibo account by bindCode', (done) ->
    options =
      method: 'POST'
      url: '/union/forcebind/weibo'
      body:
        accountToken: util.user.accountToken
        bindCode: util.bindCode
    util.request options, (err, res, user) ->
      user.should.have.properties 'accountToken', 'refer', 'openId'
      done err

  it 'should unbind weibo account', (done) ->
    options =
      method: 'POST'
      url: '/union/unbind/weibo'
      body:
        accountToken: util.user.accountToken
    util.request options, (err, res, user) ->
      user.should.not.have.properties 'refer', 'openId'
      done err

  it 'should bind weibo account again', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/weibo'
      body:
        accountToken: util.user.accountToken
        code: 'xxx'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  it 'should change the weibo account', (done) ->
    options =
      method: 'POST'
      url: '/union/change/weibo'
      body:
        accountToken: util.user.accountToken
        code: 'xxx'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  after util.cleanup
