###*
 * Indexes:
 * - db.favorites.ensureIndex({favoritedBy: 1, message: 1}, {background: true, unique: true})
 * - db.favorites.ensureIndex({favoritedBy: 1, team: 1, _id: -1}, {background: true})
###

{Schema} = require 'mongoose'
MessageSchemaConstructor = require './constructors/message'

module.exports = FavoriteSchema = MessageSchemaConstructor()

POPULATE_FIELDS = 'room creator to story'

FavoriteSchema.add
  favoritedBy: type: Schema.Types.ObjectId, ref: 'User'
  favoritedAt: type: Date, default: Date.now
  message: type: Schema.Types.ObjectId, ref: 'Message'

FavoriteSchema.virtual '_favoritedById'
  .get -> @favoritedBy?._id or @favoritedBy
  .set (_id) -> @favoritedBy = _id

FavoriteSchema.virtual '_messageId'
  .get -> @message?._id or @message
  .set (_id) -> @message = _id

FavoriteSchema.methods.getPopulated = (callback) -> @populate POPULATE_FIELDS, callback

FavoriteSchema.methods.index = (options = {}, callback = ->) ->
  return # @osv
  if toString.call(options) is '[object Function]'
    callback = options
    options = {}
  return callback() if @isSystem
  SearchFavoriteModel = @model 'SearchFavorite'
  searchFavorite = new SearchFavoriteModel @toJSON()
  searchFavorite.index options, callback

FavoriteSchema.methods.unIndex = (options = {}, callback = ->) ->
  return # @osv
  if toString.call(options) is '[object Function]'
    callback = options
    options = {}
  return callback() if @isSystem
  SearchFavoriteModel = @model 'SearchFavorite'
  searchFavorite = new SearchFavoriteModel @toJSON()
  searchFavorite.unIndex options, callback

FavoriteSchema.statics.findByIds = (_ids, callback) ->
  @find _id: $in: _ids
  .populate POPULATE_FIELDS
  .exec callback

FavoriteSchema.statics.findByOptions = (options, callback) ->
  {_sessionUserId, _teamId} = options
  @_buildQuery
    favoritedBy: _sessionUserId
    team: _teamId
  , options
  .populate POPULATE_FIELDS
  .exec callback
