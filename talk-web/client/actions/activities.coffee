
recorder = require 'actions-recorder'

api = require '../network/api'

exports.get = (_teamId, _maxId, success, fail) ->
  config =
    queryParams: switch
      when _maxId?
        _teamId: _teamId
        _maxId: _maxId
        limit: 10
      else
        _teamId: _teamId
        limit: 10
  api.activities.read.get(config)
  .then (resp) ->
    recorder.dispatch 'activities/read', _teamId: _teamId, activities: resp
    success? resp
  .catch (error) ->
    fail? error

exports.remove = (_activityId, success, fail) ->
  config =
    pathParams:
      id: _activityId
  api.activities.remove.delete(config)
  .then (resp) ->
    recorder.dispatch 'activities/remove', resp
    success? resp
  .catch (error) ->
    fail? error
