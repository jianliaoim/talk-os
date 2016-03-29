{Schema} = require 'mongoose'
config = require 'config'
mongoosastic = require 'mongoosastic'
SearchMessageSchemaConstructor = require './constructors/search-message'

module.exports = SearchFavoriteSchema = SearchMessageSchemaConstructor()

return # @osv

SearchFavoriteSchema.add
  _favoritedById:
    type: Schema.Types.ObjectId
    es_index: 'not_analyzed'
  _messageId:
    type: Schema.Types.ObjectId
    es_index: 'not_analyzed'
  favoritedAt: type: Date

SearchFavoriteSchema.plugin mongoosastic,
  index: 'talk_favorites_v2'
  type: 'favorites'
  host: config.searchHost
  port: config.searchPort
  protocol: config.searchProtocol
  bulk: config.searchBulk or size: 1000, delay: 3000
