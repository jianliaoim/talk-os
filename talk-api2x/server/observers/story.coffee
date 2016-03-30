Promise = require 'bluebird'
limbo = require 'limbo'
logger = require 'graceful-logger'

util = require '../util'
{socket} = require '../components'

{
  StoryModel
  SearchStoryModel
  MemberModel
} = limbo.use 'talk'

###*
 * Broadcast new event through websocket
###
_broadcast = (story, event) ->
  channels = story._memberIds.map (_memberId) -> "user:#{_memberId}"
  socket.broadcast channels, event, story, story.socketId

StorySchema = StoryModel.schema

StorySchema.pre 'save', (callback) ->
  story = this
  @_wasNew = @isNew
  # Broadcast story:update event
  @_wasModified = ['category', 'data', 'members'].some (field) ->
    story.isDirectModified field

  if @isNew
    # Add creator as the first member
    story = this
    hasCreator = story._memberIds.some (_memberId) -> "#{_memberId}" is "#{story._creatorId}"
    story.members.push story._creatorId unless hasCreator

  callback()

StorySchema.post 'save', (story) ->
  if story._wasNew
    story.emit 'create', story
  else if story._wasModified
    story.emit 'updated', story

StorySchema.post 'create', (story) ->

  $story = story.getPopulatedAsync()

  $story.then (story) -> _broadcast story, 'story:create'

  return # @osv
  # Index story search data
  story.indexSearch()

StorySchema.post 'updated', (story) ->
  $story = story.getPopulatedAsync()
  $story.then (story) -> _broadcast story, 'story:update'
  return # @osv
  # Index story search data
  story.indexSearch()

StorySchema.post 'remove', (story) ->
  _broadcast story, 'story:remove'
  return # @osv
  # unIndex story search data
  story.unIndexSearch()
