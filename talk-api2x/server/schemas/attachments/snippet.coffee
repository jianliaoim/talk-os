{Schema} = require 'mongoose'
util = require '../../util'

module.exports = SnippetSchema = new Schema
  codeType: String
  title: String
  text: type: String
