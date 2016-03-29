{Schema} = require 'mongoose'
util = require '../../util'

module.exports = QuoteSchema = new Schema
  category: String  # Category of integration
  userAvatarUrl: type: String, get: util.buildCamoUrl  # User avatar from the integration website
  userName: String  # User name from the integration website
  title: String  # Title of quote text, it will be used in search in the first place
  text: type: String  # Quote text, plain text or html
  imageUrl: type: String, get: util.buildCamoUrl
  redirectUrl: type: String, get: util.attachFromUrl  # The original url
  faviconUrl: type: String, get: util.buildCamoUrl
