# Search message schema

{Schema} = require 'mongoose'
_ = require 'lodash'
lexer = require 'talk-lexer'
Promise = require 'bluebird'
util = require '../../util'

module.exports = SearchMessageSchemaConstructor = ->
  SearchMessageSchema = new Schema
    _creatorId:
      type: Schema.Types.ObjectId
      es_index: 'not_analyzed'
    _teamId:
      type: Schema.Types.ObjectId
      es_index: 'not_analyzed'
    _roomId:
      type: Schema.Types.ObjectId
      es_index: 'not_analyzed'
    _toId:
      type: Schema.Types.ObjectId
      es_index: 'not_analyzed'
    _storyId:
      type: Schema.Types.ObjectId
      es_index: 'not_analyzed'
    body:
      type: String
      set: lexer.stringify
      es_term_vector: "with_positions_offsets"
      es_analyzer: "ik_max_word"
    attachments: [
      category:
        type: String
        es_index: 'not_analyzed'
      data:
        category:
          type: String
          es_index: 'not_analyzed'
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
        codeType:
          type: String
          es_index: 'not_analyzed'
        remindAt:
          type: Date
    ]
    createdAt: type: Date
    updatedAt: type: Date

  SearchMessageSchema
