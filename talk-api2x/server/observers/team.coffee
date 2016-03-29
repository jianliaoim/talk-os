limbo = require 'limbo'
Promise = require 'bluebird'
Err = require 'err1st'
serviceLoader = require 'talk-services'

{
  TeamModel
} = limbo.use 'talk'

_initNewTeam = (callback) ->
  team = this
  RoomModel = @model 'Room'
  MemberModel = @model 'Member'

  # Save general room
  room = new RoomModel
    team: team._id
    isGeneral: true
    topic: 'general'
    creator: team._creatorId

  $room = room.$save()

  # Add team owner
  ownerMember = new MemberModel
    user: team._creatorId
    team: team._id
    joinAt: new Date
    role: 'owner'

  $ownerMember = ownerMember.$save()

  # Add talkai after general room created
  $talkai = serviceLoader.getRobotOf 'talkai'

  $talkai = Promise.all [$talkai, $room]
  .spread (talkai, room) -> team.addMemberAsync talkai

  Promise.all [$room, $ownerMember, $talkai]

  .nodeify callback

TeamSchema = TeamModel.schema

TeamSchema.pre 'save', (callback) ->
  if @isNew
    return _initNewTeam.call this, callback
  else callback()
