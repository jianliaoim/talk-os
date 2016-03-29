dispatcher = require '../dispatcher'

lang = require '../locales/lang'
notifyActions = require '../actions/notify'
api = require '../network/api'

exports.updateInTeam = (_teamId, _userId, data, success, fail) ->
  config =
    pathParams:
      id: _teamId
    data: data
  api.teams.prefs.put(config)
    .then (resp) ->
      data =
        _userId: _userId
        resp: resp
      dispatcher.handleViewAction
        type: 'contact-prefs/update'
        data: data
      success? resp
    .catch (error) ->
      fail? error
