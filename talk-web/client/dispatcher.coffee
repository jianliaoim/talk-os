
EventEmitter = require 'wolfy87-eventemitter'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
dev = require './util/dev'

module.exports = emitter = new EventEmitter

emitter.handleServerAction = (action) ->
  action.source = 'server'
  emitter.emit 'action', action
  # dev.info action
  recorder.dispatch action.type, action.data

emitter.handleViewAction = (action) ->
  action.source = 'view'
  emitter.emit 'action', action
  # dev.info action
  recorder.dispatch action.type, action.data
