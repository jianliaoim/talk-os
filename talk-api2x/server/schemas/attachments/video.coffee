# File attachment schema

{Schema} = require 'mongoose'
striker = require '../../components/striker'

module.exports = VideoSchema = new Schema
  fileKey: String
  fileName: String
  fileType: String
  fileSize: Number
  fileCategory: String
  duration: Number  # Duration of video
  height: Number
  width: Number

VideoSchema.virtual 'downloadUrl'
  .get -> striker.downloadUrl this

VideoSchema.virtual 'previewUrl'
  .get -> striker.previewUrl this
