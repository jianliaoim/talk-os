{Schema} = require 'mongoose'
util = require '../../util'

module.exports = MessageSchema = new Schema
  creator: Object
  team: type: Schema.Types.ObjectId
  room: Object
  to: Object
  body: type: String
  isSystem: type: Boolean, default: false
  icon: type: String, default: 'normal'
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now

MessageSchema.virtual '_creatorId'
  .get -> @creator?._id

MessageSchema.virtual '_roomId'
  .get -> @room?._id

MessageSchema.virtual '_toId'
  .get -> @to?._id

MessageSchema.virtual '_teamId'
  .get -> @team
