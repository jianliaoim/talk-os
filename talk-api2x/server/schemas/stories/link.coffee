# RTF story

{Schema} = require 'mongoose'
util = require '../../util'

module.exports = LinkSchema = new Schema
  url: type: String
  title: type: String
  text: type: String
  imageUrl: type: String, get: util.buildCamoUrl
  faviconUrl: type: String, get: util.buildCamoUrl
