_ = require 'lodash'
Promise = require 'bluebird'
Err = require 'err1st'

# Bind static methods
statics =
  # Similar to findOneAndUpdate, But this method will apply the getter/setters
  # Process findOne/save/create
  # @warning: this function is not atomic
  findOneAndSave: (conditions, update, options, callback = ->) ->
    if typeof options is 'function'
      callback = options
      options = {}

    if options.keep instanceof Array  # These properties will not override old properties
      options.keep = ['createdAt'].concat(options.keep)
    else
      options.keep = ['createdAt']

    self = this

    @findOne conditions, (err, doc) ->
      if doc?
        _update = {}
        for key, val of update
          continue if key in options.keep
          continue if _.isEqual val, doc[key]
          _update[key] = val
          doc[key] = val

        # Do not call update when the update field is empty
        return callback(null, doc) if _.isEmpty(_update)

        doc.updatedAt = new Date
        # Ignore the numberAffected param
        doc.save (err, doc) -> callback err, doc

      else if options.upsert

        conditions = _.extend conditions, update
        conditions.createdAt = new Date
        conditions.updatedAt = new Date
        self.create conditions, callback

      else callback null, null

  # Find items and remove
  findAndRemove: (conditions, callback = ->) ->
    @find conditions, (err, items = []) =>
      return callback(err) if err?
      @remove conditions, (err) -> callback err, items

  # Common options to query collections
  _buildQuery: (conditions, options = {}) ->
    {maxDate, limit, _maxId, _minId, sort, page} = options

    page or= 1
    limit or= 30

    conditions.createdAt = $lt: maxDate if maxDate?

    sort or= _id: -1
    if _maxId
      conditions._id or= {}
      conditions._id.$lt = _maxId
    else if _minId
      conditions._id or= {}
      conditions._id.$gt = _minId
      sort = _id: 1

    query = @find conditions
      .limit Number(limit)
      .skip limit * (page - 1)
      .sort sort

# Bind instance methods
methods =
  $save: ->
    model = this
    new Promise (resolve, reject) ->
      model.save (err, model) ->
        return reject(err) if err
        resolve model
  $remove: ->
    model = this
    new Promise (resolve, reject) ->
      model.remove (err, model) ->
        return reject(err) if err
        resolve model

# Overwrite embed methods
overwrites = {}

schemas =
  User: require './user'
  Room: require './room'
  Member: require './member'
  Message: require './message'
  Team: require './team'
  File: require './file'
  Preference: require './preference'
  Integration: require './integration'
  Invitation: require './invitation'
  DeviceToken: require './devicetoken'
  Favorite: require './favorite'
  Tag: require './tag'
  Voip: require './voip'
  Story: require './story'
  Notification: require './notification'
  Mark: require './mark'
  Group: require './group'
  Usage: require './usage'
  UsageHistory: require './usage-history'
  Activity: require './activity'
  # Accessible for both api and cms
  Notice: require './notice'
  # Search messages
  SearchMessage: require './search-message'
  SearchFavorite: require './search-favorite'
  SearchStory: require './search-story'
  # Attachments
  fileAttachment: require './attachments/file'
  messageAttachment: require './attachments/message'
  quoteAttachment: require './attachments/quote'
  rtfAttachment: require './attachments/rtf'
  snippetAttachment: require './attachments/snippet'
  speechAttachment: require './attachments/speech'
  videoAttachment: require './attachments/video'
  calendarAttachment: require './attachments/calendar'
  # Stories
  fileStory: require './stories/file'
  linkStory: require './stories/link'
  topicStory: require './stories/topic'

module.exports =
  schemas: schemas
  statics: statics
  methods: methods
  overwrites: overwrites
