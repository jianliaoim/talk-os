###*
 * 邀请列表
 * 索引
 * db.invitations.ensureIndex({team: 1}, {background: true})
 * db.invitations.ensureIndex({room: 1}, {background: true})
 * db.invitations.ensureIndex({key: 1, team: 1, room: 1}, {unique: true, background: true})
###
Err = require 'err1st'
_ = require 'lodash'
{Schema} = require 'mongoose'

module.exports = InvitationSchema = new Schema
  name: type: String
  email: type: String
  mobile: type: String
  key: type: String
  room: type: Schema.Types.ObjectId, ref: 'Room'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  role: type: String, default: 'member'
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

InvitationSchema.virtual '_roomId'
  .get -> @room?._id or @room
  .set (_id) -> @room = _id

InvitationSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

InvitationSchema.virtual 'isInvite'
  .get -> true

InvitationSchema.statics.invite = (conditions, callback = ->) ->
  InvitationModel = this

  {email, mobile, name, key} = conditions

  if conditions.mobile
    conditions.key or= "mobile_#{conditions.mobile}"
    conditions.name or= conditions.mobile
  else if conditions.email
    conditions.key or= "email_#{conditions.email}"
    conditions.name or= conditions.email.split?('@')[0]

  return callback(new Err('PARAMS_MISSING', 'key')) unless conditions.key

  unless (['room', 'team'].some (key) -> conditions[key])
    return callback(new Err('PARAMS_MISSING', 'room, team'))

  $invitation = InvitationModel.findOneAsync _.pick(conditions, 'key', 'room', 'team')

  $invitation = $invitation.then (invitation) ->
    throw new Err('INVITATION_EXISTING') if invitation
    invitation = new InvitationModel conditions
    invitation.$save()

  $invitation.nodeify callback
