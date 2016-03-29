Promise = require 'bluebird'
Err = require 'err1st'
_ = require 'lodash'
async = require 'async'

util = require '../util'
limbo = require 'limbo'
favoriteSearcher = require '../searchers/favorite'
app = require '../server'

{
  MessageModel
  FavoriteModel
  MemberModel
} = limbo.use 'talk'

module.exports = favoriteController = app.controller 'favorite', ->

  @mixin require './mixins/permission'

  @ratelimit '60 300', only: 'search'

  @ensure '_messageId', only: 'create'
  @ensure '_teamId', only: 'read search'
  @ensure '_favoriteIds', only: 'batchRemove reposts'

  @before 'creatableFavorite', only: 'create'
  @before 'editableFavorite', only: 'remove repost'
  @before 'editableFavorites', only: 'batchRemove reposts'
  @before 'accessibleMessage', only: 'repost reposts'

  @action 'read', (req, res, callback) -> FavoriteModel.findByOptions req.get(), callback

  @action 'create', (req, res, callback) ->
    {message, _sessionUserId} = req.get()

    $favorite = FavoriteModel.findOneAsync
      favoritedBy: _sessionUserId
      message: message._id

    .then (favorite) ->
      _messageId = message._id
      _favorite = _.omit message.toJSON(), '_id'
      if favorite
        favorite.favoritedAt = new Date
      else
        favorite = new FavoriteModel
          favoritedBy: _sessionUserId
          favoritedAt: new Date
          message: _messageId

      Object.keys(_favorite).forEach (key) ->
        favorite[key] = _favorite[key] unless key is '__v'

      new Promise (resolve, reject) ->
        favorite.save (err, favorite) ->
          return reject(err) if err
          resolve favorite

    .then (favorite) -> favorite.getPopulatedAsync()

    .then (favorite) ->
      res.broadcast "user:#{_sessionUserId}", "favorite:create", favorite
      favorite

    .nodeify callback

  @action 'remove', (req, res, callback) ->
    {_id, favorite, _sessionUserId} = req.get()
    favorite.remove (err, favorite) ->
      return callback(err) if err
      callback err, favorite
      res.broadcast "user:#{_sessionUserId}", "favorite:remove", favorite

  @action 'batchRemove', (req, res, callback) ->
    {_favoriteIds, _sessionUserId, favorites} = req.get()

    Promise.resolve favorites

    .map (favorite) ->
      favorite.$remove()
      .then (favorite) ->
        res.broadcast "user:#{_sessionUserId}", "favorite:remove", favorite
        favorite

    .then (favorites) -> favorites

    .nodeify callback

  @action 'search', (req, res, callback) -> favoriteSearcher.search req, res, callback

  @action 'repost', (req, res, callback) ->
    {_id, favorite, _sessionUserId, _roomId, _teamId, _toId, _storyId} = req.get()
    _message = favorite.toObject virtuals: false, getters: false
    _message = _.pick _message, [
      'body'
      'authorName'
      'authorAvatarUrl'
      'attachments'
      'isSystem'
      'icon'
      'displayType'
    ]
    repost = new MessageModel _message
    repost.creator = _sessionUserId
    repost.team = _teamId
    if _roomId
      repost.room = _roomId
    else if _toId
      repost.to = _toId
    else if _storyId
      repost.story = _storyId
    else return callback(new Err('PARAMS_MISSING', '_roomId', '_toId', '_teamId', '_storyId'))
    repost.save (err, repost) ->
      return callback err if err
      repost.getPopulated callback

  @action 'reposts', (req, res, callback) ->
    {_id, favorites, _roomId, _teamId, _toId, _sessionUserId, _storyId} = req.get()
    async.map favorites, (favorite, next) ->
      _message = favorite.toObject virtuals: false, getters: false
      _message = _.pick _message, [
        'body'
        'authorName'
        'authorAvatarUrl'
        'attachments'
        'isSystem'
        'icon'
        'displayType'
      ]
      repost = new MessageModel _message
      repost.creator = _sessionUserId
      repost.team = _teamId
      if _roomId
        repost.room = _roomId
      else if _toId
        repost.to = _toId
      else if _storyId
        repost.story = _storyId
      else return callback(new Err('PARAMS_MISSING', '_roomId', '_toId', '_teamId', '_storyId'))
      repost.save (err, repost) ->
        return next err if err
        repost.getPopulated next
    , callback
