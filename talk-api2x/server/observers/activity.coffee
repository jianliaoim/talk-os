limbo = require 'limbo'
logger = require 'graceful-logger'
{socket} = require '../components'

{
  ActivityModel
} = limbo.use 'talk'

ActivitySchema = ActivityModel.schema

ActivitySchema.pre 'save', (callback) ->
  @_wasNew = @isNew
  @updatedAt = new Date unless @isNew
  callback()

ActivitySchema.post 'save', (activity) ->
  if @_wasNew
    activity.emit 'create', activity
  else
    activity.emit 'updated', activity

ActivitySchema.post 'create', (activity) ->
  activity.getPopulatedAsync().then (activity) ->
    if activity.isPublic
      socket.broadcast "team:#{activity._teamId}", "activity:create", activity, activity.socketId
    else
      channels = activity.members?.map (_memberId) -> "user:#{_memberId}"
      socket.broadcast channels, "activity:create", activity, activity.socketId

ActivitySchema.post 'updated', (activity) ->
  activity.getPopulatedAsync().then (activity) ->
    if activity.isPublic
      socket.broadcast "team:#{activity._teamId}", "activity:update", activity, activity.socketId
    else
      channels = activity.members?.map (_memberId) -> "user:#{_memberId}"
      socket.broadcast channels, "activity:update", activity, activity.socketId

ActivitySchema.post 'remove', (activity) ->
  if activity.isPublic
    socket.broadcast "team:#{activity._teamId}", "activity:remove", activity, activity.socketId
  else
    channels = activity.members?.map (_memberId) -> "user:#{_memberId}"
    socket.broadcast channels, "activity:remove", activity, activity.socketId

