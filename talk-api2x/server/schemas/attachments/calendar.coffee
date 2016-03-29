# Calendar attachment

{Schema} = require 'mongoose'

module.exports = CalendarSchema = new Schema
  remindAt: type: Date, required: true
