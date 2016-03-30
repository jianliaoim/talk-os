###*
 * Indexes:
 * - db.messages.ensureIndex({team: 1, creator: 1, to: 1, _id: -1}, {background: true})
 * - db.messages.ensureIndex({room: 1, _id: -1}, {background: true})
 * - db.messages.ensureIndex({story: 1, _id: -1}, {background: true})
 * - db.messages.ensureIndex({tags: 1, team: 1, _id: -1}, {background: true})
 * - db.messages.ensureIndex({mark: 1, team: 1, _id: -1}, {background: true})
 * - db.messages.ensureIndex({'attachments.category': 1, team: 1, _id: -1, 'attachments.data.fileCategory': 1}, {background: true})
 * - db.messages.ensureIndex({mentions: 1, team: 1, _id: -1}, {background: true})
 * - db.messages.ensureIndex({team: 1, hasTag: 1, _id: -1}, {background: true})
###

mongoose = require 'mongoose'
{Schema} = mongoose
_ = require 'lodash'
uuid = require 'uuid'
Err = require 'err1st'
Promise = require 'bluebird'
lexer = require 'talk-lexer'
config = require 'config'
moment = require 'moment'
util = require '../util'
MessageSchemaConstructor = require './constructors/message'
redis = require '../components/redis'

module.exports = MessageSchema = MessageSchemaConstructor()

MessageSchema.add
  tags: [
    type: Schema.Types.ObjectId, ref: 'Tag'
  ]
  hasTag: type: Boolean, default: false
  mark: type: Schema.Types.ObjectId, ref: 'Mark'
  receiptors: [
    type: Schema.Types.ObjectId, ref: 'User'
  ]

MessageSchema.virtual 'notification'
  .get -> @_notification
  .set (@_notification) -> @_notification

POPULATE_FIELDS = ['room', 'creator', 'to', 'tags', 'story', 'mark']

_getFileCategories = (fileCategory) ->
  switch fileCategory
    when 'image' then fileCategories = ['image']
    when 'document' then fileCategories = ['text', 'pdf', 'message']
    when 'media' then fileCategories = ['audio', 'video']
    when 'other' then fileCategories = ['application', 'font']
    else fileCategories = []
  fileCategories

_buildConditions = (options) ->
  {_creatorId, _teamId, _toId, _roomId, _storyId} = options
  _teamId or= options.team

  conditions = {}
  conditions = team: _teamId if _teamId

  switch
    when options._roomId
      conditions.room = options._roomId
    when options._storyId
      conditions.story = options._storyId
    when options._toId and options._creatorId and _teamId
      conditions.to = $in: [options._creatorId, options._toId]
      conditions.creator = $in: [options._creatorId, options._toId]
    else throw new Err('PARAMS_MISSING', '_toId', '_roomId', '_storyId')

  conditions.mark = options._markId if options._markId

  if options._tagId
    conditions.tags = options._tagId
  else if options.hasTag
    conditions.hasTag = true

  conditions.mentions = options._mentionId if options._mentionId

  conditions._id = options._id if options._id?
  conditions.isSystem = options.isSystem if options.isSystem?

  conditions['attachments.category'] = options.category if options.category

  if options.fileCategory
    conditions['attachments.category'] = 'file'
    conditions['attachments.data.fileCategory'] = $in: _getFileCategories(options.fileCategory)

  return conditions

_queryBesides = (_besideId, options, callback = ->) ->
  delete options._maxId
  delete options._minId
  # Before conditions
  beforeOptions = _.clone options
  beforeOptions._id = $lte: _besideId
  # After conditions
  afterOptions = _.clone options
  afterOptions._id = $gt: _besideId
  afterOptions.sort or= {}
  afterOptions.sort._id = 1

  self = this

  Promise.map [beforeOptions, afterOptions], (options) ->
    conditions = _buildConditions options
    new Promise (resolve, reject) ->
      self._buildQuery.call(self, conditions, options).populate(POPULATE_FIELDS).exec (err, messages) ->
        return reject(err) if err
        resolve messages

  .then ([beforeMessages, afterMessages]) ->
    messages = [].concat beforeMessages, afterMessages
    .sort (x, y) -> if y._id > x._id then 1 else -1

  .nodeify callback

MessageSchema.methods.readableByUser = (_userId, callback) ->
  # If this is a direct message, _userId should be either _creatorId or _toId
  return callback(null, this) if "#{@_toId}" is _userId or "#{@_creatorId}" is _userId
  return callback(new Err('NO_PERMISSION')) unless @_roomId

  # Then if this is a room message, _userId should be room member
  self = this
  MemberSchema = @model 'Member'
  MemberSchema.findOne
    room: @_roomId
    user: _userId
    isQuit: false
  , (err, member) ->
    return callback(new Err('NO_PERMISSION')) unless member
    callback err, self

MessageSchema.methods.setIntegration = (callback) ->
  message = this
  {integration} = message
  return callback(null, message) unless integration

  # Set quote infomation from integration
  _setIntegration = ->
    {integration, attachments} = message
    return unless integration

    attachments?.forEach (attachment) ->
      return unless attachment
      {category, data} = attachment
      return unless category is 'quote' and data
      data.category = integration?.category

    message.authorName or= integration?.title
    message.authorAvatarUrl or= integration?.iconUrl
    message._roomId or= integration?._roomId
    message._teamId or= integration?._teamId

  if integration?._id
    _setIntegration()
    return callback null, message
  else  # Not populated integration
    message.populate 'integration', (err, message) ->
      return callback(err, message) if err
      _setIntegration()
      callback err, message

MessageSchema.methods.setMentions = (callback) ->
  message = this
  MemberModel = @model "Member"
  StoryModel = @model 'Story'

  cmdGroup = lexer.parse(message.body) or []
  _mentionIds = []

  Promise.resolve(cmdGroup)

  .map (cmdObj) ->

    if cmdObj.cmd is 'at'

      if cmdObj.data is 'all'

        switch
          when message._roomId
            MemberModel.findAsync
              room: message._roomId
              isQuit: false
            , 'user'
            .map (member) -> "#{member._userId}"
            .then (members) -> _mentionIds = _mentionIds.concat (members)

          when message._storyId
            StoryModel.findOneAsync
              _id: message._storyId
            , 'members'
            .then (story) -> _mentionIds = _mentionIds.concat story?.members or []

          else return

      else if /^[0-9a-fA-F]{24}$/.test cmdObj.data
        _mentionIds.push (cmdObj.data)

  .then (mentionIds = []) ->
    _mentionIds = _mentionIds.filter (_mentionId) -> "#{_mentionId}" isnt "#{message._creatorId}"
    message.mentions = _.uniq _mentionIds
    message

  .nodeify callback

MessageSchema.methods.getPopulated = (callback) ->
  self = this
  unless self.$populating
    self.$populating = Promise.promisify(self.populate).call self, POPULATE_FIELDS

  self.$populating.nodeify callback

MessageSchema.methods.getSearchIndex = ->
  message = this
  "talk_messages_" + moment(message.createdAt).format('YYYYMM')

MessageSchema.methods.index = (options = {}, callback = ->) ->
  return # @osv
  if toString.call(options) is '[object Function]'
    callback = options
    options = {}
  return callback() if @isSystem
  SearchMessageModel = @model 'SearchMessage'
  searchMessage = new SearchMessageModel @toJSON()

  options.index = @getSearchIndex()

  searchMessage.index options, callback

MessageSchema.methods.unIndex = (options = {}, callback = ->) ->
  return # @osv
  if toString.call(options) is '[object Function]'
    callback = options
    options = {}
  return callback() if @isSystem
  SearchMessageModel = @model 'SearchMessage'
  searchMessage = new SearchMessageModel @toJSON()

  options.index = @getSearchIndex()

  searchMessage.unIndex options, callback

# Query messages by this method
MessageSchema.statics.findByOptions = (options, callback) ->
  options._creatorId or= options._sessionUserId
  # Query the messages beside this id
  return _queryBesides.call this, options._besideId, options, callback if options._besideId
  try
    conditions = _buildConditions options
  catch err
    return callback err

  @_buildQuery.call(this, conditions, options).populate(POPULATE_FIELDS).exec callback

MessageSchema.statics.findMessagesFromRoom = (_roomId, options, callback) ->
  options._roomId = _roomId
  @findByOptions options, callback

MessageSchema.statics.findMessagesWithUser = (_toId, _creatorId, _teamId, options, callback) ->
  {_besideId} = options
  options._toId = _toId
  options._creatorId = _creatorId
  options._teamId = _teamId
  @findByOptions options, callback

MessageSchema.statics.findLatestMessageFromRoom = (_roomId, options = {}, callback = ->) ->
  options.limit = 1
  @findMessagesFromRoom _roomId, options, (err, messages = []) -> callback err, messages[0]

MessageSchema.statics.findLatestMessageWithUser = (_toId, _creatorId, _teamId, options = {}, callback = ->) ->
  options.limit = 1
  @findMessagesWithUser _toId, _creatorId, _teamId, options, (err, messages = []) -> callback err, messages[0]

MessageSchema.statics.readableByUser = (_id, _userId, callback = ->) ->
  @findOne _id: _id, (err, message) ->
    return callback(new Err 'OBJECT_MISSING', "message #{_id}") unless message
    message.readableByUser _userId, callback

MessageSchema.statics.findByIds = (_ids, callback) ->
  @find _id: $in: _ids
  .populate POPULATE_FIELDS
  .exec callback

MessageSchema.statics.setMsgToken = (data, callback = ->) ->
  msgToken = uuid.v4()
  key = "msgtoken:#{msgToken}"
  expire = 1800

  redis.multi()
  .hmset key, data
  .expire key, expire
  .exec (err) -> callback err, msgToken

MessageSchema.statics.getMsgToken = (msgToken, callback) ->
  key = "msgtoken:#{msgToken}"
  redis.hgetall key, callback

MessageSchema.statics.clearMsgToken = (msgToken, callback = ->) ->
  key = "msgtoken:#{msgToken}"
  redis.del key, callback

MessageSchema.statics.getUrlContent = (url, callback = ->) ->

  cacheKey = "talkurl:#{url}"
  cacheExpires = 86400

  $attachmentOptions = redis.getAsync cacheKey
  .then (data) ->
    try
      attachmentOptions = JSON.parse data
    catch err
      attachmentOptions = false

    if attachmentOptions
      attachmentOptions.cached = true
      return attachmentOptions

    util.fetchUrlMetas url
    .then (meta = {}) ->
      {title, description, imageUrl, faviconUrl, contentType} = meta
      if contentType is 'image'
        util.fetchAndSaveRemoteImg url
        .then (fileData = {}) ->
          fileOptions = fileData
          fileOptions.type = 'image'
          return fileOptions
      else
        title and= title.trim()
        description and= description.trim()
        return unless title?.length or description?.length
        quoteOptions =
          category: 'url'
          title: title
          text: description
          imageUrl: imageUrl
          redirectUrl: url
          faviconUrl: faviconUrl
          type: 'text'
        return quoteOptions

  $attachment = $attachmentOptions.then (attachmentOptions = {}) ->
    if attachmentOptions.type
      optionType = attachmentOptions.type
      _attachmentOptions = _.omit attachmentOptions, 'type', 'cached'
      switch optionType
        when 'text'
          attachment =
            category: 'quote'
            data: _attachmentOptions
        when 'image'
          attachment =
            category: 'file'
            data: _attachmentOptions
      return attachment

  $setCache = $attachmentOptions.then (attachmentOptions = {}) ->
    if attachmentOptions.type and not attachmentOptions.cached
      redis.setex cacheKey, cacheExpires, JSON.stringify attachmentOptions

  Promise.all [$attachment, $setCache]
  .spread (attachment) -> attachment
  .nodeify callback

# Build readable conditions for user
# When visiting all the objects from team
# These conditions must combined with other conditions
# Like mentions or tags
MessageSchema.statics.buildOverallTeamConditions = (_userId, _teamId, options, callback) ->
  MemberModel = @model 'Member'
  RoomModel = @model 'Room'
  TeamModel = @model 'Team'
  StoryModel = @model 'Story'

  conditions = team: _teamId

  options._types or= ['room', 'story', 'dms']

  # Room message
  if 'room' in options._types
    $roomConditions = TeamModel.findJoinedRoomIdsAsync _teamId, _userId
    .then (_roomIds) ->
      return unless _roomIds?.length
      room: $in: _roomIds
  else
    $roomConditions = Promise.resolve()

  # Story message
  if 'story' in options._types
    $storyConditions = StoryModel.find
      team: _teamId
      members: _userId
    , '_id'
    .sort _id: -1
    .limit 30
    .execAsync()
    .then (stories) ->
      return unless stories?.length
      story: $in: stories.map (story) -> "#{story._id}"
  else
    $storyConditions = Promise.resolve()

  # DMS
  if 'dms' in options._types
    $dmsConditions = MemberModel.findAsync
      team: _teamId
      isQuit: false
    , 'user'
    .then (members) ->
      return unless members?.length
      _toIds = members.map (member) -> "#{member.user}"
      return {
        $or: [{
          # Others to me
          to: _userId
          creator: $in: _toIds
        }, {
          # I to others
          to: $in: _toIds
          creator: _userId
        }]
      }
  else
    $dmsConditions = Promise.resolve()

  Promise.all [$roomConditions, $storyConditions, $dmsConditions]
  .spread (roomConditions, storyConditions, dmsConditions) ->
    conditions.$or = [roomConditions, storyConditions, dmsConditions].filter (cond) -> cond
    conditions
  .nodeify callback

###*
 * Find all messages which mention this user
 * @param  {ObjectId}   _userId
 * @param  {ObjectId}   _teamId
 * @param  {Object}   options  Query options, page, limit, etc.
 * @param  {Function} callback messages
###
MessageSchema.statics.findAllMentions = (_userId, _teamId, options, callback) ->
  MessageModel = this
  # Only story and room can have mentions
  options._types = ['story', 'room']

  $conditions = MessageModel.buildOverallTeamConditionsAsync _userId, _teamId, options
  .then (conditions) ->
    # Remove dms
    conditions.mentions = _userId
    conditions

  $messages = $conditions.then (conditions) ->
    $query = MessageModel
    ._buildQuery conditions, options
    .populate POPULATE_FIELDS

    $query = $query.hint mentions: 1, team: 1, _id: -1 unless config.test

    $query.execAsync()

  .nodeify callback

###*
 * Find all the tagged messages
 * Or find messages by one _tagId
 * @param  {ObjectId}   _userId
 * @param  {ObjectId}   _teamId
 * @param  {Object}   options  Query options, page, limit, etc.
 * @param  {Function} callback messages
###
MessageSchema.statics.findAllTags = (_userId, _teamId, options, callback) ->
  MessageModel = this

  $conditions = MessageModel.buildOverallTeamConditionsAsync _userId, _teamId, options

  .then (conditions) ->
    if options._tagId
      conditions.tags = options._tagId
    else
      conditions.hasTag = true
    conditions

  $messages = $conditions.then (conditions) ->
    $query = MessageModel
    ._buildQuery conditions, options
    .populate POPULATE_FIELDS

    $query.execAsync()

  .nodeify callback
