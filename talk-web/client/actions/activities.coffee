recorder = require 'actions-recorder'

api = require '../network/api'

exports.ACTIVITIES_READ_LIMIT = 10

requestActivities = (config, _teamId, success, fail) ->
  api.activities.read.get config
    .then (resp) ->
      recorder.dispatch 'activities/read',
        _teamId: _teamId
        activities: resp
      success? resp
    .catch (error) ->
      fail? error

exports.get = (_teamId, success, fail) ->
  exports.loading _teamId, 'down'

  config =
    queryParams:
        _teamId: _teamId
        limit: exports.ACTIVITIES_READ_LIMIT

  api.activities.read.get config
    .then (res) ->
      recorder.dispatch 'activities/initial',
        _teamId: _teamId
        direction: 'down'
        activities: res
      success? res
    .catch (error) ->
      fail? error

exports.getByMinId = (_teamId, _minId, success, fail) ->
  exports.loading _teamId, 'up'

  config =
    queryParams:
      _minId: _minId
      _teamId: _teamId
      limit: exports.ACTIVITIES_READ_LIMIT

  api.activities.read.get config
    .then (res) ->
      recorder.dispatch 'activities/read',
        _teamId: _teamId
        direction: 'up'
        activities: res
      success? res
    .catch (error) ->
      fail? error

exports.getByMaxId = (_teamId, _maxId, success, fail) ->
  exports.loading _teamId, 'down'

  config =
    queryParams:
      _maxId: _maxId
      _teamId: _teamId
      limit: exports.ACTIVITIES_READ_LIMIT

  api.activities.read.get config
    .then (res) ->
      recorder.dispatch 'activities/read',
        _teamId: _teamId
        direction: 'down'
        activities: res
      success? res
    .catch (error) ->
      fail? error

exports.getByMaxDate = (_teamId, maxDate, success, fail) ->
  exports.loading _teamId, 'down'

  config =
    queryParams:
      _teamId: _teamId
      maxDate: maxDate
      limit: exports.ACTIVITIES_READ_LIMIT

  api.activities.read.get config
    .then (resp) ->
      recorder.dispatch 'activities/replace',
        _teamId: _teamId
        activities: resp
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

exports.loading = (_teamId, direction) ->
  recorder.dispatch 'activities/loading',
    _teamId: _teamId
    direction: direction
