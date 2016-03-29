should = require 'should'
limbo = require 'limbo'
db = limbo.use 'talk'
async = require 'async'
app = require '../../app'
{clear, request} = app

prepare = (done) ->
  async.auto
    prepare: app.prepare
    createGuestUser: (callback) ->
      options =
        method: 'post'
        url: 'guest/users'
        body: JSON.stringify
          name: 'guest1'
          email: 'guest1@somedomain.com'
      request options, (err, res, user) ->
        app.guest1 = user
        callback err
  , done

describe 'guest/user#create', ->

  before app.prepare

  it 'should create a guest user', (done) ->

    options =
      method: 'post'
      url: 'guest/users'
      body: JSON.stringify
        name: 'guest'
        email: 'guest@somedomain.com'
    request options, (err, res, user) ->
      user.should.have.properties 'name', 'email'
      user.isGuest.should.eql true
      done err

  after clear

describe 'guest/user#update', ->

  before prepare

  it 'should update a guest user', (done) ->

    options =
      method: 'put'
      url: "guest/users/#{app.guest1._id}"
      body: JSON.stringify
        _sessionUserId: app.guest1._id
        name: 'newguest'
        email: 'newguest@a.com'
    request options, (err, res, user) ->
      user.name.should.eql 'newguest'
      user.email.should.eql 'newguest@a.com'
      done err

  after clear

describe 'guest1/user#signout', ->

  before prepare

  it 'should signout the user and leave the rooms', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'room:leave'
            data.should.have.properties '_roomId', '_userId'
            data._userId.should.eql app.guest1._id
            callback()
      joinRoom: (callback) ->
        options =
          method: 'post'
          url: "guest/rooms/#{app.room1.guestToken}/join"
          body: JSON.stringify
            _sessionUserId: app.guest1._id
        request options, callback
      signout: ['joinRoom', (callback) ->
        options =
          method: 'post'
          url: "guest/users/signout"
          body: JSON.stringify
            _sessionUserId: app.guest1._id
        request options, callback
      ]
    , done

  after clear
