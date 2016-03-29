
recorder = require 'actions-recorder'

exports.create = (activity) ->
  recorder.dispatch 'activities/create', activity

exports.remove = (activity) ->
  recorder.dispatch 'activities/remove', activity

exports.update = (activity) ->
  recorder.dispatch 'activities/update', activity
