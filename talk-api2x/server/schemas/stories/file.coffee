# File story schema

FileSchemaConstructor = require '../constructors/file'

module.exports = FileSchema = FileSchemaConstructor()

FileSchema.add
  text: String
