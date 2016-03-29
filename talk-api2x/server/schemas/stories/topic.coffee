{Schema} = require 'mongoose'
util = require '../../util'

module.exports = TopicSchema = new Schema
  title: String
  text: String
