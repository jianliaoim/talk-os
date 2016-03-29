###
Indexes:
* db.groups.ensureIndex({team: 1}, {background: true})
###

{Schema} = require 'mongoose'
_ = require 'lodash'

module.exports = GroupSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  name: type: String
  members: [
    type: Schema.Types.ObjectId, ref: 'User'
  ]
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
GroupSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

GroupSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

GroupSchema.virtual '_memberIds'
  .get ->
    @members.map (member) -> member?._id or member
      .filter (_memberId) -> _memberId
  .set (_memberIds) ->
    @members = _memberIds
# ============================== methods ==============================
