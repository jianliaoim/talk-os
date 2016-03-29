should = require 'should'
async = require 'async'
app = require '../../app'
{clear, request} = app

prepare = (done) ->
  async.auto
    prepare: app.prepare
    createGuestUser: app.createGuestUser
  , done

describe 'Guest.Room#ReadOne', ->

  before prepare

  it 'should get the room info and nested team infomation', (done) ->
    options =
      method: 'get'
      url: 'guest/rooms/' + app.room1.guestToken
    request options, (err, res, room) ->
      room.should.have.properties 'team', 'topic'
      room.should.not.have.properties 'members', 'latestMessages'
      room.team.should.have.properties 'name'
      done err

  after clear

describe 'Guest.Room#Join', ->

  before prepare

  it 'should join a room and get detail infomation of this room', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          hits = 0
          if event is 'room:join'
            hits |= 0b1
            data.should.have.properties 'name', 'avatarUrl', '_roomId'
            data._roomId.should.eql app.room1._id
          callback() if hits is 0b1
      join: (callback) ->  # Join user2 to the room
        options =
          method: 'post'
          url: "guest/rooms/#{app.room1.guestToken}/join"
          body: JSON.stringify
            _sessionUserId: app.guest1._id
        request options, (err, res, room) ->
          room.should.have.properties '_teamId', 'topic', 'members', 'latestMessages', 'unread'
          (room.members.some (member) -> member._id is app.user1._id).should.eql true
          room.members.forEach (member) -> member.should.not.have.properties 'email', 'mobile'
          callback err
    , done

  after clear

describe 'Guest.Room#Leave', ->

  before prepare

  it 'should leave the room and recieve the history message email', (done) ->
    async.auto
      join: (callback) ->
        options =
          method: 'post'
          url: "guest/rooms/#{app.room1.guestToken}/join"
          body: JSON.stringify
            _sessionUserId: app.guest1._id
        setTimeout ->
          request options, callback
        , 1000
      # Create messages by user1
      createMessages: ['join', (callback) ->
        options =
          method: 'post'
          url: 'messages'
          body: JSON.stringify
            _sessionUserId: app.user1._id
            _roomId: app.room1._id
            body: 'Hello Guest'
        request options, callback
      ]
      leave: ['createMessages', (callback) ->
        options =
          method: 'post'
          url: "guest/rooms/#{app.room1._id}/leave"
          body: JSON.stringify
            _sessionUserId: app.guest1._id
        request options, callback
      ]
      mailer: (callback) ->
        app.mailer = (email) ->
          {messages, to} = email
          to.should.eql app.guest1.email
          messages.length.should.eql 1
          callback()
    , done

  after clear
