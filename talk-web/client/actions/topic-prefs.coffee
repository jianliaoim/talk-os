dispatcher = require '../dispatcher'

lang = require '../locales/lang'
notifyActions = require '../actions/notify'
api = require '../network/api'

exports.update = (_roomId, data, success, fail) ->
  config =
    pathParams:
      id: _roomId
    data: data
  api.rooms.prefs.put(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic-prefs/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error
