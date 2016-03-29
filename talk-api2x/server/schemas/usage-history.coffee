###*
 * db.usagehistories.createIndex({team: 1, type: 1}, {background: true})
###

mongoose = require 'mongoose'

{Schema} = mongoose

module.exports = UsageSchema = new Schema
  amount: type: Number
  type: type: String, required: true
  team: type: Schema.Types.ObjectId, ref: 'Team', required: true
  data: type: Schema.Types.Mixed
  createdAt: type: Date, default: Date.now
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true
