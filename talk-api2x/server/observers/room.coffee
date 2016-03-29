serviceLoader = require 'talk-services'
Promise = require 'bluebird'
Err = require 'err1st'
util = require '../util'
{limbo, socket, logger} = require '../components'

{
  IntegrationModel
  MemberModel
  RoomModel
  NotificationModel
} = limbo.use 'talk'

_removeIntegrations = (room) ->
  IntegrationModel.findAndRemove room: room._id, (err, integrations = []) ->
    integrations.forEach (integration) ->
      $service = serviceLoader.load integration.category
      $service.then (service) -> service.receiveEvent 'integration.remove', integration
      .catch (err) -> logger.warn err.stack

      socket.broadcast "team:#{integration._teamId}", "integration:remove", integration

_initNewRoom = (callback) ->
  room = this
  @email or= util.randomEmail @topic
  # Set creator to room owner
  MemberModel = @model 'Member'
  member = new MemberModel
    user: room._creatorId
    room: room._id
    joinAt: new Date
    role: 'owner'
  member.save (err, member) ->
    room.memberCount += 1
    callback err

RoomSchema = RoomModel.schema

RoomSchema.pre 'save', (callback) ->
  if @isNew
    _initNewRoom.call this, callback
  else callback()

# Remove integrations when remove room
RoomSchema.post 'remove', (room) ->
  _removeIntegrations room

  NotificationModel.removeByOptionsAsync target: room._id, team: room._teamId
  .catch (err) -> logger.warn err.stack
  # Remove room members
  MemberModel.remove room: room._id

RoomSchema.post 'archive', (room) ->
  _removeIntegrations room

  NotificationModel.removeByOptionsAsync target: room._id, team: room._teamId
  .catch (err) -> logger.warn err.stack
