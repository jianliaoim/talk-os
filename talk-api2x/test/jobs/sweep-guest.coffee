should = require 'should'
async = require 'async'
app = require '../app'
{clear, request} = app
sweepGuestJob = require '../../server/jobs/sweep-guest'

prepare = (done) ->
  async.auto
    prepare: app.prepare
    createGuestUser: app.createGuestUser
  , done

describe 'Job#SweepGuest', ->

  before (done) ->
    async.auto
      prepare: prepare
      joinRoom: ['prepare', (callback) ->
        setTimeout ->
          options =
            method: 'post'
            url: "guest/rooms/#{app.room1.guestToken}/join"
            body: JSON.stringify
              _sessionUserId: app.guest1._id
          request options, callback
        , 1000
      ],
      sendMessage: ['joinRoom', (callback) ->
        options =
          method: 'post'
          url: "guest/messages"
          body: JSON.stringify
            _sessionUserId: app.guest1._id
            body: 'HI'
            _roomId: app.room1._id
        request options, callback
      ]
    , done

  it 'should remove the guest from room and send messages to user', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'room:leave'
            data._userId.should.eql app.guest1._id
            data._roomId.should.eql app.room1._id
            callback()
      mailer: (callback) ->
        app.mailer = (email) ->
          {messages, to} = email
          to.should.eql app.guest1.email
          messages.length.should.eql 1  # Message HI
          callback()
      sweepGuest: (callback) ->
        sweepGuestJob app.guest1._id
        .nodeify callback
    , done

  after clear
