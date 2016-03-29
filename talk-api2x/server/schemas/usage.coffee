###*
 * db.usages.createIndex({team: 1, type: 1, month: 1}, {unique: true, background: true})
###

mongoose = require 'mongoose'
util = require '../util'

{Schema} = mongoose

module.exports = UsageSchema = new Schema
  amount: type: Number, default: 0
  maxAmount: type: Number, default: 0, required: true
  team: type: Schema.Types.ObjectId, ref: 'Team', required: true
  type: type: String, required: true
  month: type: Date, default: util.getCurrentMonth, required: true
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

# ============ Virtuals ============

UsageSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

# ============ Methods ============

# ============ Statics ============
UsageSchema.statics.incr = (_teamId, type, incrAmount, callback) ->
  UsageModel = this
  month = util.getCurrentMonth()

  conditions =
    team: _teamId
    type: type
    month: month

  update = $inc: amount: incrAmount

  options = upsert: true

  UsageModel.update conditions, update, options, callback
