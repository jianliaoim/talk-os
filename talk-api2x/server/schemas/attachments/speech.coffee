# File attachment schema

{Schema} = require 'mongoose'
striker = require '../../components/striker'
util = require '../../util'

module.exports = SpeechSchema = new Schema
  fileKey: String
  fileName: String
  fileType: String
  fileSize: Number
  fileCategory: String
  duration: Number  # Duration of speech

SpeechSchema.virtual 'downloadUrl'
  .get -> striker.downloadUrl this

SpeechSchema.virtual 'previewUrl'
  .get -> striker.previewUrl this
