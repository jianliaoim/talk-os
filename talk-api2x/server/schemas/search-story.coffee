{Schema} = require 'mongoose'
config = require 'config'
mongoosastic = require 'mongoosastic'
util = require '../util'

module.exports = SearchStorySchema = new Schema
  _creatorId:
    type: Schema.Types.ObjectId
    es_index: 'not_analyzed'
  _teamId:
    type: Schema.Types.ObjectId
    es_index: 'not_analyzed'
  category:
    type: String
    es_index: 'not_analyzed'
  data:
    url:
      type: String
      es_term_vector: 'with_positions_offsets'
      es_analyzer: 'ik_smart'
    title:
      type: String
      es_term_vector: 'with_positions_offsets'
      es_analyzer: 'ik_max_word'
    text:
      type: String
      es_term_vector: 'with_positions_offsets'
      es_analyzer: 'ik_smart'
      set: util.stripHtml
    fileType:
      type: String
      es_index: 'not_analyzed'
    fileCategory:
      type: String
      es_index: 'not_analyzed'
    fileName:
      type: String
      es_term_vector: 'with_positions_offsets'
      es_analyzer: 'ik_max_word'
    fileSize:
      type: Number
      es_type: 'long'
    duration:
      type: Number
      es_type: 'long'
  _memberIds: [
    type: Schema.Types.ObjectId
  ]
  createdAt: type: Date
  updatedAt: type: Date

return # @osv

SearchStorySchema.add
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

SearchStorySchema.plugin mongoosastic,
  index: 'talk_stories_v2'
  type: 'stories'
  host: config.searchHost
  port: config.searchPort
  protocol: config.searchProtocol
  bulk: config.searchBulk or size: 1000, delay: 3000
