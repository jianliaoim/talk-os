should = require 'should'
async = require 'async'
limbo = require 'limbo'
app = require '../../app'
{clear, request} = app

{
  MessageModel
} = limbo.use 'talk'

prepare = (done) ->
  async.auto
    prepare: app.prepare
    createGuestUser: app.createGuestUser
    createMessage: ['prepare', (callback) ->
      message = new MessageModel
        body: 'Hi'
        creator: app.user1._id
        team: app.team1._id
        room: app.room1._id
      message.save (err, message) -> callback err, message
    ]
  , done

describe 'Guest/Message#Read', ->

  before prepare

  it 'should not read the messages before the date guest join the room', (done) ->
    async.auto
      joinRoom: (callback) ->
        options =
          method: 'post'
          url: "guest/rooms/#{app.room1.guestToken}/join"
          body: JSON.stringify
            _sessionUserId: app.guest1._id
        setTimeout ->
          request options, callback
        , 1000
      readMessages: ['joinRoom', (callback) ->
        options =
          method: 'get'
          url: "guest/messages"
          qs:
            _roomId: app.room1._id
            _sessionUserId: app.guest1._id
        request options, (err, res, messages) ->
          # Only contain the 'join room' inform message
          messages.length.should.eql 1
          done err
      ]
    , done

  after clear
