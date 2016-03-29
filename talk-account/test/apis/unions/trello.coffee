should = require 'should'
request = require 'supertest'
jwt = require 'jsonwebtoken'
app = require '../../../server/server'
util = require '../../util'

rq = require 'request'

describe 'Union#Trello', ->

  before util.prepare

  it 'should redirect to trello account page when visit redirect url', (done) ->
    request(app).get '/union/trello'
    .end (err, res) ->
      res.statusCode.should.eql 302
      location = res.headers.location
      location.should.eql 'http://127.0.0.1:7632/tl/OAuthAuthorizeToken?oauth_token=trello_request_token_step_1&name=TalkIM'
      done()

  it 'should create new account with oauth_token and oauth_verifier from trello account api', (done) ->
    options =
      method: 'POST'
      url: '/union/signin/trello'
      body:
        oauth_token: 'trello_authorize_token_step_2'
        oauth_verifier: 'trello_authorize_verifier_step_2'
    util.request options, (err, res, user) ->
      user.should.have.properties 'name', 'refer', 'openId', 'accountToken', 'wasNew', 'showname'
      user.wasNew.should.eql true
      user.name.should.eql 'trello 用户'
      user.showname.should.eql '简聊'
      user.openId.should.eql '1234567'
      {_id, login} = jwt.decode user.accountToken
      login.should.eql 'trello'
      util.user = user
      done err

  it 'should not bind to an exist trello account', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/trello'
      body:
        accountToken: util.user.accountToken
        oauth_token: 'trello_authorize_token_step_2'
        oauth_verifier: 'trello_authorize_verifier_step_2'
    util.request options, (err, res, body) ->
      err.message.should.eql '绑定账号已存在'
      err.data.should.have.properties 'bindCode'
      util.bindCode = err.data.bindCode
      done()

  it 'should bind to an exist trello account by bindCode', (done) ->
    options =
      method: 'POST'
      url: '/union/forcebind/trello'
      body:
        accountToken: util.user.accountToken
        bindCode: util.bindCode
    util.request options, (err, res, user) ->
      user.should.have.properties 'accountToken', 'refer', 'openId'
      done err

  it 'should unbind trello account', (done) ->
    options =
      method: 'POST'
      url: '/union/unbind/trello'
      body:
        accountToken: util.user.accountToken
    util.request options, (err, res, user) ->
      user.should.not.have.properties 'refer', 'openId'
      done err

  it 'should bind trello account again', (done) ->
    options =
      method: 'POST'
      url: '/union/bind/trello'
      body:
        accountToken: util.user.accountToken
        oauth_token: 'trello_authorize_token_step_2'
        oauth_verifier: 'trello_authorize_verifier_step_2'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  it 'should change the trello account', (done) ->
    options =
      method: 'POST'
      url: '/union/change/trello'
      body:
        accountToken: util.user.accountToken
        oauth_token: 'trello_authorize_token_step_2'
        oauth_verifier: 'trello_authorize_verifier_step_2'
    util.request options, (err, res, user) ->
      user.should.have.properties 'refer', 'openId'
      done err

  after util.cleanup
