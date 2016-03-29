_ = require 'lodash'
Promise = require 'bluebird'
Err = require 'err1st'

statics =
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

  createIfNotExist: (conditions, update, callback = ->) ->
    Model = this
    Model.findOne conditions
    , (err, model) ->
      return callback(new Err('OBJECT_EXISTING')) if model
      _conditions = _.clone conditions
      model = new Model _.assign(_conditions, update)
      _update = model.toJSON()
      delete _update._id
      delete _update.id
      Model.findOneAndUpdate conditions
      , _update
      ,
        upsert: true
        new: true
      , (err, model) ->
        callback err, model

  findAndRemove: (conditions, callback = ->) ->
    @find conditions, (err, items = []) =>
      return callback(err) if err?
      @remove conditions, (err) -> callback err, items

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
      .limit limit
      .skip limit * (page - 1)
      .sort sort

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

overwrites = {}

schemas =
  User: require './user'
  Union: require './union'
  Email: require './email'
  Mobile: require './mobile'

module.exports =
  schemas: schemas
  statics: statics
  methods: methods
  overwrites: overwrites
