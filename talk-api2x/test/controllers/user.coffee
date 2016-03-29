should = require 'should'
limbo = require 'limbo'
uuid = require 'uuid'
db = limbo.use 'talk'
async = require 'async'
jwt = require 'jsonwebtoken'
util = require '../../server/util'
config = require 'config'
app = require '../app'
{prepare, clear, request} = app

{
  MemberModel
  UserModel
} = db

describe 'User#ReadOne', ->

  before prepare

  it 'should read infomation of myself', (done) ->
    options =
      method: 'get'
      url: 'users/me'
      qs:
        _sessionUserId: app.user1._id
    request options, (err, res, user) ->
      user.should.have.properties 'name', 'avatarUrl', 'email', 'phoneForLogin', 'mobile'
      done(err)

  after clear

describe 'User#Read', ->

  before prepare

  it 'should read the users by email', (done) ->
    options =
      method: 'GET'
      url: '/users'
      qs:
        _sessionUserId: app.user1._id
        q: 'user2@teambition.com'
    request options, (err, res, users) ->
      users.length.should.eql 1
      users[0].name.should.eql 'dajiangyou2'
      done err

  it 'should read the users by mobile number', (done) ->
    options =
      method: 'GET'
      url: '/users'
      qs:
        _sessionUserId: app.user1._id
        q: '13388888881'
    request options, (err, res, users) ->
      users.length.should.eql 1
      done err

  it 'should read the users by mobiles', (done) ->
    options =
      method: 'GET'
      url: '/users'
      qs:
        _sessionUserId: app.user1._id
        mobiles: '13388888881,13388888882'
    request options, (err, res, users) ->
      users.length.should.eql 2
      done err

  after clear

describe 'User#Update', ->

  before prepare

  it 'should update user name to xjx', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data, socketId) ->
          if event is 'user:update'
            data.should.have.properties 'name', 'avatarUrl'
            data.name.should.eql 'xjx'
            callback()
      update: (callback) ->
        options =
          method: 'put'
          url: "users/#{app.user1._id}"
          body: JSON.stringify
            name: 'xjx'
            _sessionUserId: app.user1._id
        request options, (err, res, user) ->
          user.should.have.properties 'phoneForLogin', 'mobile'
          user.name.should.eql 'xjx'
          user.pinyin.should.eql 'xjx'
          user.pinyins.should.eql ['xjx']
          callback err
    , done

  after clear

describe 'User#Subscribe', ->

  before prepare

  it 'should subscribe to the user channel', (done) ->
    options =
      method: 'post'
      url: 'users/subscribe'
      headers: "X-Socket-Id": uuid.v1()
      body:
        _sessionUserId: app.user1._id
    app.request options, (err, res, result) ->
      result.should.eql ok: 1
      done err

  after clear

describe 'User#Unsubscribe', ->

  before prepare

  it 'should unsubscribe to the user channel', (done) ->
    options =
      method: 'post'
      url: 'users/unsubscribe'
      headers: "X-Socket-Id": uuid.v1()
      body: _sessionUserId: app.user1._id
    app.request options, (err, res, result) ->
      result.should.eql ok: 1
      done err

  after clear

describe 'User#landing', ->

  before prepare

  it "should broadcast union's access token and refer attributes", (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'integration:gettoken'
            data.should.have.properties "accessToken", "showname", 'openId', 'avatarUrl', 'openId'
            data.showname.should.eql "github"
            callback()

      createUser: (callback) ->
        user = new UserModel
          name: "jianliao"
          accountId: "55f7d19c85efe377996a1232"
        app.user = user
        user.$save().nodeify callback

      gettoken: ['createUser', (callback) ->
        options =
          method: 'get'
          url: '/union/github/landing'
          body: JSON.stringify
            _sessionUserId: app.user._id
            accountToken: 'OKKKKKKK'
        app.request options, callback
      ]
    , done
  after clear
