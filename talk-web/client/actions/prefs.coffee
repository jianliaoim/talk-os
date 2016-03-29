dispatcher = require '../dispatcher'

api = require '../network/api'

exports.silentUpdate = (data) ->
  dispatcher.handleViewAction {type: 'prefs/update', data}

# FIXME: 某个地方同时调用了这个action两次
exports.prefsUpdate = (data, success, fail) ->
  api.preferences.update.put(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'prefs/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error
