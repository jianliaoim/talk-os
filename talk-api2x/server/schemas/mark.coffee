###*
 * db.marks.ensureIndex({team: 1, target: 1, x: 1, y: 1}, {unique: true, background: true})
###

mongoose = require 'mongoose'
Err = require 'err1st'
{Schema} = mongoose
_ = require 'lodash'

module.exports = MarkSchema = new Schema
  team: type: Schema.Types.ObjectId, ref: 'Team'
  creator: type: Schema.Types.ObjectId, ref: 'User'
  target: type: Schema.Types.ObjectId
  type: type: String  # Target type
  text: type: String
  x: type: Number, required: true
  y: type: Number, required: true
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

MarkSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

MarkSchema.virtual '_targetId'
  .get -> @target?._id or @target
  .set (_id) -> @target = _id

MarkSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

MarkSchema.statics.createByOptions = (options, callback) ->
  requiredFields = ['team', 'target', 'type', 'x', 'y']
  unless (requiredFields.every (field) -> options[field])
    return callback(new Err('PARAMS_MISSING', requiredFields))

  unless options.type is 'story'
    return callback(new Err('INVALID_MAKR_TARGET'))

  MarkModel = this

  conditions = _.pick options, 'team', 'target', 'x', 'y'

  $mark = MarkModel.findOneAsync conditions

  $mark = $mark.then (mark) ->
    return mark if mark
    mark = new MarkModel options
    mark.$save()

  $mark.nodeify callback
