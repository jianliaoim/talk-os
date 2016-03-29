###*
 * Transform methods to statics
###
Err = require 'err1st'

module.exports = makestatic = (schema, options) ->
  {methodNames} = options

  methodNames.forEach (methodName) ->
    unless schema.methods[methodName]
      throw new Err("Instance method #{methodName} is not existing")
    if schema.statics[methodName]
      throw new Err("Static method #{methodName} is existing")

    schema.statics[methodName] = (_id, args...) ->
      Model = this
      return _id[methodName].apply _id, args if _id instanceof Model
      if toString.call(args[args.length - 1]) is '[object Function]'
        callback = args[args.length - 1]
      else
        callback = ->
      Model.findOne _id: _id, (err, model) ->
        return callback(new Err("OBJECT_MISSING", "#{model?.modelName} #{_id}")) unless model
        model[methodName].apply model, args
