shortid = require 'shortid'
time = require '../util/time'

dispatcher = require '../dispatcher'

['warn', 'error', 'info', 'success'].forEach (method) ->
  exports[method] = (text, config = {}) ->

    _id = shortid.generate()
    dispatcher.handleViewAction
      type: 'notify/create'
      data:
        _id: _id
        type: method
        text: text
        config: config

    time.delay 3000, ->
      exports.remove _id

exports.remove = (_id) ->
  dispatcher.handleViewAction
    type: 'notify/remove'
    data:
      _id: _id
