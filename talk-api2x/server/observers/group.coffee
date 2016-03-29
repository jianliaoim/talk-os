limbo = require 'limbo'
logger = require 'graceful-logger'
{socket} = require '../components'

{
  GroupModel
} = limbo.use 'talk'

GroupSchema = GroupModel.schema

GroupSchema.pre 'save', (callback) ->
  @_wasNew = @isNew
  callback()

GroupSchema.post 'save', (group) ->
  if @_wasNew
    group.emit 'create', group
  else
    group.emit 'updated', group

GroupSchema.post 'create', (group) ->
  socket.broadcast "team:#{group._teamId}", "group:create", group, group.socketId

GroupSchema.post 'updated', (group) ->
  socket.broadcast "team:#{group._teamId}", "group:update", group, group.socketId

GroupSchema.post 'remove', (group) ->
  socket.broadcast "team:#{group._teamId}", "group:remove", group, group.socketId

