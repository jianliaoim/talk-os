###
# Sub accounts from http://www.yuntongxun.com/
# * Indexes:
# * - db.voips.ensureIndex({user: 1}, {unique: true, background: true})
###
Err = require 'err1st'
{Schema} = require 'mongoose'
util = require '../util'

module.exports = VoipSchema = new Schema
  user: type: Schema.Types.ObjectId, ref: 'User'
  voipAccount: String
  voipPwd: String
  subToken: String
  subAccountSid: String
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

VoipSchema.virtual '_userId'
  .get -> @user?._id or @user
  .set (_id) -> @user = _id
