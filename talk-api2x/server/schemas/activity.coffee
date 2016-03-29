###*
 * Indexes:
 * - db.activities.ensureIndex({team: 1, isPublic: 1, members: 1, createdAt: -1}, {background: true})
 * - db.activities.ensureIndex({target: 1}, {background: true})
###

{Schema} = require 'mongoose'
_ = require 'lodash'
Promise = require 'bluebird'
Err = require 'err1st'

module.exports = ActivitySchema = new Schema
  team: type: Schema.Types.ObjectId, ref: 'Team', required: true
  target: type: Schema.Types.ObjectId
  type: type: String
  creator: type: Schema.Types.ObjectId, ref: 'User'
  isPublic: type: Boolean, default: false
  members: [
    type: Schema.Types.ObjectId, ref: 'User'
  ]
  text: type: String
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

ActivitySchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

ActivitySchema.virtual '_targetId'
  .get -> @target?._id or @target
  .set (_id) -> @target = _id

ActivitySchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

# ============================== Methods ==============================

ActivitySchema.methods.getPopulated = (callback) ->
  activity = this

  unless activity.$populating

    switch activity.type
      when 'room' then modelName = 'Room'
      when 'dms' then modelName = 'User'
      when 'story' then modelName = 'Story'
      else callback null, activity
    activity.$populating = Promise.promisify activity.populate
    .call activity, [
      path: 'target'
      model: modelName
    ,
      path: 'creator'
    ]

  activity.$populating.nodeify callback

# ============================== Statics ==============================

###*
 * Find activities by options
 * @param  {Object}   options - Should contain `team` and `user` params
 * @param  {Function} callback
###
ActivitySchema.statics.findByOptions = (options, callback) ->
  requiredFields = ['team', 'user']
  missingFields = requiredFields.reduce (fields, key) ->
    fields.push key unless options[key]
    fields
  , []
  return callback(new Err('PARAMS_MISSING', missingFields)) if missingFields.length

  ActivityModel = this

  conditions =
    team: options.team
    $or: [
      isPublic: true
    ,
      members: options.user
    ]

  options.sort = createdAt: -1

  if options.maxDate
    conditions.createdAt = $lt: options.maxDate
  else if options.minDate
    conditions.createdAt = $gte: options.minDate
    options.sort = createdAt: 1

  $activities = @_buildQuery(conditions, options).execAsync()

  .map (activity) -> activity.getPopulatedAsync()

  .nodeify callback
