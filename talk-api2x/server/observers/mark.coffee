limbo = require 'limbo'
logger = require 'graceful-logger'
{socket} = require '../components'

{
  MarkModel
  MessageModel
} = limbo.use 'talk'

MarkSchema = MarkModel.schema

MarkSchema.post 'remove', (mark) ->
  conditions =
    team: mark.team
    mark: mark._id
  update = $unset: mark: 1
  options = multi: true

  $removeMsgMark = MessageModel.updateAsync conditions, update, options

  $removeMsgMark.catch (err) -> logger.warn err.stack

  socket.broadcast "team:#{mark.team}", "mark:remove", mark, mark.socketId

