limbo = require 'limbo'
Promise = require 'bluebird'
logger = require 'graceful-logger'
{socket} = require '../components'

{
  TagModel
  MessageModel
  SearchMessageModel
} = limbo.use 'talk'

TagModel.schema.pre 'save', (next) ->
  @_wasNew = @isNew
  next()

TagModel.schema.post 'save', (tag) ->
  if tag._wasNew
    tag.emit 'create', tag
  else
    tag.emit 'updated', tag

TagModel.schema.post 'create', (tag) ->
  socket.broadcast "team:#{tag._teamId}", "tag:create", tag, tag.socketId

TagModel.schema.post 'updated', (tag) ->
  conditions =
    tags: tag._id
    team: tag._teamId

  $updateSearch = MessageModel.find conditions
  .populate 'tags'
  .execAsync()
  .map (message) -> message.index()
  .catch (err) -> logger.err err.stack

  socket.broadcast "team:#{tag._teamId}", "tag:update", tag, tag.socketId

TagModel.schema.post 'remove', (tag) ->
  # Remove tags from messages
  conditions =
    team: tag._teamId
    tags: tag._id

  # Update search messages before remove message tags
  # Otherwise these message will not be able to be queried
  $messages = MessageModel.find conditions
  .populate 'tags'
  .execAsync()

  $updateSearch = $messages.map (message) ->
    message.tags = message.tags?.map (tag) -> tag?._id
    message.index()

  $removeMsgTags = $messages.then ->
    update = $pull: tags: tag._id
    options = multi: true
    MessageModel.updateAsync conditions, update, options

  Promise.all [$updateSearch, $removeMsgTags]
  .catch (err) -> logger.err err.stack

  # Broadcast messages
  socket.broadcast "team:#{tag._teamId}", "tag:remove", tag, tag.socketId
