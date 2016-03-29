should = require 'should'
async = require 'async'
_ = require 'lodash'
app = require '../app'
{prepare, clear, request} = app
limbo = require('limbo')

{
  MessageModel
  FavoriteModel
} = limbo.use 'talk'

_createMessage = (callback) ->
  MessageModel.create
    creator: app.user1._id
    room: app.room1._id
    team: app.team1._id
    body: 'hello'
  , (err, message) ->
    app.message1 = JSON.parse(JSON.stringify(message))
    callback err

_createFavorite = (callback) ->
  _messageId = app.message1._id
  _message = _.omit app.message1, '_id'
  favorite = new FavoriteModel _message
  favorite.message = _messageId
  favorite.favoritedBy = app.user1._id
  favorite.save (err, favorite) ->
    app.favorite1 = JSON.parse(JSON.stringify(favorite))
    callback err

describe 'Favorite#Create', ->

  before (done) ->
    async.auto
      prepare: prepare
      _createMessage: ['prepare', _createMessage]
    , done

  it 'should save the message to favorite list', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'favorite:create'
            data.should.have.properties '_teamId', '_creatorId', '_favoritedById'
            data._favoritedById.should.eql app.user1._id
            data._messageId.should.eql app.message1._id
            callback()
      create: (callback) ->
        options =
          method: 'POST'
          url: 'favorites'
          body: JSON.stringify
            _sessionUserId: app.user1._id
            _messageId: app.message1._id
        request options, callback
    , done

  after clear

describe 'Favorite#Remove', ->

  before (done) ->
    async.auto
      prepare: prepare
      _createMessage: ['prepare', _createMessage]
      _createFavorite: ['_createMessage', _createFavorite]
    , done

  it 'should remove the favorite', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'favorite:remove'
            data.should.have.properties '_teamId', '_creatorId'
            callback()
      removeFavorite: (callback) ->
        options =
          method: 'DELETE'
          url: "favorites/#{app.favorite1._id}"
          body: JSON.stringify
            _sessionUserId: app.user1._id
        request options, callback
    , done

  after clear

describe 'Favorite#Read', ->

  before (done) ->
    async.auto
      prepare: prepare
      _createMessage: ['prepare', _createMessage]
      _createFavorite: ['_createMessage', _createFavorite]
    , done

  it 'should read the favorites list', (done) ->

    async.auto
      read: (callback) ->
        options =
          method: 'GET'
          url: 'favorites'
          qs:
            _sessionUserId: app.user1._id
            _teamId: app.team1._id
        request options, (err, res, favorites) ->
          favorites.length.should.eql 1
          callback err
    , done

  after clear

describe 'Favorite#BatchRemove', ->

  before (done) ->
    async.auto
      prepare: prepare
      _createMessage: ['prepare', _createMessage]
      _createFavorite: ['_createMessage', _createFavorite]
    , done

  it 'should remove favorites by the batchremove api', (done) ->

    async.auto
      batchRemove: (callback) ->
        options =
          method: 'POST'
          url: 'favorites/batchremove'
          qs:
            _sessionUserId: app.user1._id
            _favoriteIds: [app.favorite1._id]
        request options, done

  after clear

describe 'Favorite#Repost(s)', ->

  before (done) ->
    async.auto
      prepare: prepare
      _createMessage: ['prepare', _createMessage]
      _createFavorite: ['_createMessage', _createFavorite]
    , done

  it 'should repost favorites to other rooms', (done) ->

    _checkMessage = (message) ->
      message._creatorId.should.eql app.user1._id
      message.body.should.eql 'hello'
      message._roomId.should.eql app.room1._id
      "#{message._id}".should.not.eql "#{app.favorite1._id}"
      "#{message.createdAt}".should.not.eql "#{app.message1.createdAt}"

    async.auto
      repost: (callback) ->
        options =
          method: 'POST'
          url: "/favorites/#{app.favorite1._id}/repost"
          body:
            _roomId: app.room1._id
            _sessionUserId: app.user1._id
        app.request options, (err, res, message) ->
          _checkMessage message
          callback err
      reposts: (callback) ->
        options =
          method: 'POST'
          url: "/favorites/reposts"
          body:
            _favoriteIds: [app.favorite1._id]
            _sessionUserId: app.user1._id
            _roomId: app.room1._id
        app.request options, (err, res, messages) ->
          messages.length.should.eql 1
          messages.forEach _checkMessage
          callback err
    , done
