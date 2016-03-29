###*
 * Indexes:
 * - db.devicetokens.ensureIndex({token: 1, type: 1}, {unique: true, background: true})
 * - db.devicetokens.ensureIndex({user: 1, clientId: 1, type: 1}, {unique: true, background: true})
###

{Schema} = require 'mongoose'

module.exports = DeviceTokenSchema = new Schema
  user: type: Schema.Types.ObjectId, ref: 'User'
  token: type: String
  type: type: String, default: 'ios'
  clientId: type: String
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

DeviceTokenSchema.virtual('_userId').get -> @user?._id or @user
DeviceTokenSchema.virtual('_userId').set (_id) -> @user = _id
