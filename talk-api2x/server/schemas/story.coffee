###
Indexes:
* db.stories.ensureIndex({members: 1, team: 1, _id: -1}, {background: true})
###

mongoose = require 'mongoose'
{Schema} = require 'mongoose'
_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'
makestatic = require './plugins/makestatic'

POPULATE_FIELDS = 'creator members'

supportedStories = ['file', 'link', 'topic']

_buildConditions = (options) ->
  {_sessionUserId, _teamId, maxDate} = options
  _teamId or= options.team
  throw new Err('PARAMS_MISSING', '_teamId') unless _teamId

  conditions =
    team: _teamId
    members: _sessionUserId

  return conditions

###*
 * Apply the story data getter and cache this field
###
dataGetter = (data) ->
  return {} unless @category in supportedStories
  return unless data
  unless @_data
    category = @category
    StoryDataModel = @model "#{category}Story"
    if StoryDataModel
      @_data = new StoryDataModel(data).toObject virtuals: true, getters: true
    else
      @_data = data
  return @_data

###*
 * Remove field cache
###
dataSetter = (data) ->
  delete @_data
  return data

module.exports = StorySchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  category: type: String
  data: type: Object, set: dataSetter, get: dataGetter
  members: [
    type: Schema.Types.ObjectId, ref: 'User'
  ]
  isPublic: type: Boolean, default: false
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

################## Virtuals ##################

StorySchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

StorySchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

StorySchema.virtual '_memberIds'
  .get ->
    @members.map (member) -> member?._id or member
      .filter (_memberId) -> _memberId
  .set (_memberIds) ->
    @members = _memberIds

StorySchema.virtual 'text'
  .get -> @data.text

StorySchema.virtual 'title'
  .get ->
    title = ''
    switch @category
      when 'topic' then title = @data?.title
      when 'file' then title = @data?.fileName
      when 'link' then title = @data?.title or @data.url
    return title or ''

StorySchema.virtual 'pinnedAt'
  .get -> @_pinnedAt
  .set (@_pinnedAt) -> @_pinnedAt

StorySchema.virtual 'isPinned'
  .get -> @_isPinned
  .set (@_isPinned) -> @_isPinned

################## Hooks ##################
###*
 * Save the data property as pure story data element
###
StorySchema.pre 'save', (next) ->
  story = this
  if @data
    category = @category
    return next(new Err('INVALID_OBJECT', "story.category #{category}")) unless category in supportedStories
    StoryDataModel = @model "#{category}Story"
    _data = new StoryDataModel @data
    @data = _data.toObject virtuals: false, getters: false
  next()

################## Methods ##################

StorySchema.methods.getPopulated = (callback) -> @populate POPULATE_FIELDS, callback

StorySchema.methods.indexSearch = (callback = ->) ->
  SearchStoryModel = @model 'SearchStory'
  searchStory = new SearchStoryModel @toJSON()
  searchStory.index callback

StorySchema.methods.unIndexSearch = (callback = ->) ->
  SearchStoryModel = @model 'SearchStory'
  searchStory = new SearchStoryModel @toJSON()
  searchStory.unIndex callback

################## Statics ##################

StorySchema.statics.findByOptions = (options, callback) ->
  try
    conditions = _buildConditions options
  catch err
    return callback err
  @_buildQuery.call(this, conditions, options).populate(POPULATE_FIELDS).exec callback

StorySchema.statics.findByIds = (_storyIds, callback) ->
  @find _id: $in: _storyIds
  .populate POPULATE_FIELDS
  .exec callback
