recorder = require 'actions-recorder'

query = require '../query'
dispatcher = require '../dispatcher'

notifyActions = require '../actions/notify'

lang = require '../locales/lang'

api = require '../network/api'

# expose methods

exports.create = (data, success, fail) ->
  # data : _teamId, name, _memberIds

  api.groups.create.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'group/create'
        data: resp
      success? resp
    .catch (error) ->
      fail? error


exports.update = (_groupId, data, success, fail) ->
  # data: name, addMembers, removeMembers

  config =
    pathParams:
      id: _groupId
    data: data

  api.groups.update.put(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'group/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.read = (_teamId, success, fail) ->
  config =
    queryParams: { _teamId }

  api.groups.read.get(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'group/read'
        data:
          _teamId: _teamId
          groups: resp
      success? resp
    .catch (error) ->
      fail? error

exports.remove = (_groupId, success, fail) ->
  config =
    pathParams:
      id: _groupId

  api.groups.remove.delete(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'group/remove'
        data: resp
      success? resp
    .catch (error) ->
      fail? error
