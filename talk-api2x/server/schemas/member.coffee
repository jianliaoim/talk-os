###*
 * Indexes:
 * - db.members.ensureIndex({room: 1}, {background: true, sparse: true})
 * - db.members.ensureIndex({team: 1}, {background: true, sparse: true})
 * - db.members.ensureIndex({user: 1, room: 1, team: 1}, {unique: true, background: true})
 * - db.members.ensureIndex({user: 1, team: 1, room: 1}, {unique: true, background: true})
###

_ = require 'lodash'
{Schema} = require 'mongoose'
Err = require 'err1st'

module.exports = MemberSchema = new Schema
  user: type: Schema.Types.ObjectId, ref: 'User'
  room: type: Schema.Types.ObjectId, ref: 'Room'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  isQuit: type: Boolean, default: false
  hasVisited: type: Boolean, default: false
  joinAt: Date
  quitAt: Date
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
  # owner/admin/member
  role: type: String, default: 'member'
  prefs:
    alias: String
    isMute: type: Boolean, default: false
    hideMobile: type: Boolean, default: false  # Hide mobile in this team or room
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

MemberSchema.virtual '_userId'
  .get -> @user?._id or @user
  .set (_id) -> @user = _id

MemberSchema.virtual '_roomId'
  .get -> @room?._id or @room
  .set (_id) -> @room = _id

MemberSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

MemberSchema.statics.join = (conditions, update, callback = ->) ->
  delete conditions.isQuit
  MemberModel = this

  _userId = conditions._userId or conditions.user
  return callback(new Err('PARAMS_MISSING', '_userId')) unless _userId

  MemberModel.findOne conditions
  , (err, member) ->
    return callback(new Err('MEMBER_EXISTING')) if member?.isQuit is false  # Member exist
    date = new Date
    if member
      member.isQuit = false
      member.joinAt = date
      member.updatedAt = date
      member.role = update.role or 'member'
      member.save (err, member) -> callback err, member
    else
      _conditions = _.clone conditions
      member = new MemberModel _.assign(_conditions, update)
      _update = member.toJSON()
      delete _update._id
      delete _update.id
      MemberModel.findOneAndUpdate conditions
      , _update
      ,
        upsert: true
        new: true
      , callback
