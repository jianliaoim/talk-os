recorder = require 'actions-recorder'

exports.init = (_teamId, createdAt, currentAt, success, fail) ->
  recorder.dispatch 'timeline/init',
    _teamId: _teamId
    createdAt: createdAt
    currentAt: currentAt
  success?()
