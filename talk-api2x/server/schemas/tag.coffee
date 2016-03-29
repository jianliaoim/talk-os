###
Indexes:
* db.tags.ensureIndex({team: 1, name: 1}, {unique: true, background: true})
###

{Schema} = require 'mongoose'
_ = require 'lodash'

module.exports = TagSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  name: type: String
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

# ============================== Virtuals ==============================
TagSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

TagSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id
# ============================== methods ==============================
