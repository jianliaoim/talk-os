# File attachment schema

{Schema} = require 'mongoose'
striker = require '../../components/striker'
util = require '../../util'

module.exports = FileSchemaConstructor = ->
  FileSchema = new Schema
    fileKey: String
    fileName: String
    fileType: String
    fileSize: Number
    fileCategory: String
    imageWidth: Number
    imageHeight: Number

  FileSchema.virtual 'downloadUrl'
    .get -> striker.downloadUrl this

  FileSchema.virtual 'thumbnailUrl'
    .get -> striker.thumbnailUrl this, width: 400, height: 400

  FileSchema.virtual 'previewUrl'
    .get -> striker.previewUrl this

  FileSchema
