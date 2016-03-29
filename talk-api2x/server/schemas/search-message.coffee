{Schema} = require 'mongoose'
config = require 'config'
mongoosastic = require 'mongoosastic'
SearchMessageSchemaConstructor = require './constructors/search-message'

module.exports = SearchMessageSchema = SearchMessageSchemaConstructor()

return # @osv

SearchMessageSchema.add
  tags: [
    _tagId:
      type: Schema.Types.ObjectId
      es_index: 'not_analyzed'
      get: -> @_id
    name:
      type: String
      es_term_vector: 'with_positions_offsets'
      es_analyzer: 'ik_max_word'
  ]

SearchMessageSchema.plugin mongoosastic,
  index: 'talk_messages_recent'
  type: 'messages'
  host: config.searchHost
  port: config.searchPort
  protocol: config.searchProtocol
  bulk: config.searchBulk or size: 1000, delay: 3000
