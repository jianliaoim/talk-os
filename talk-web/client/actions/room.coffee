recorder = require 'actions-recorder'

query = require '../query'
dispatcher = require '../dispatcher'

notifyActions = require '../actions/notify'

lang = require '../locales/lang'

api = require '../network/api'

# expose methods

exports.fetch = (_roomId, success, fail) ->
  api.rooms.readone.get(pathParams: id: _roomId)
    .then (resp) ->
      dispatcher.handleViewAction type: 'topic/fetch', data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.roomJoin = (_teamId, _roomId, success, fail) ->
  api.rooms.join.post(pathParams: id: _roomId)
    .then (resp) ->
      dispatcher.handleViewAction type: 'topic/fetch', data: resp
      data = query.user(recorder.getState()).toJS()
      data._teamId = _teamId
      data._roomId = resp._id
      dispatcher.handleViewAction type: 'topic/join', data: data
      success? resp
    .catch (error) ->
      fail? error

exports.roomLeave = (_teamId, _roomId, success, fail) ->
  _userId = query.user(recorder.getState()).get('_id')
  api.rooms.leave.post(pathParams: id: _roomId)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/leave'
        data: {_roomId, _userId, _teamId}
      success? resp
    .catch (error) ->
      fail? error

exports.roomInvite = (_roomId, data, success, fail) ->
  config =
    pathParams:
      id: _roomId
    data: data
  api.rooms.invite.post(config)
    .then (resp) ->
      dispatcher.handleViewAction type: 'topic/join', data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.roomCreate = (data, success, fail) ->
  api.rooms.create.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/create'
        data: resp
      notifyActions.success lang.getText('create-topic-success')
      success? resp
    .catch (error) ->
      fail? error

exports.roomRemove = (_roomId, success, fail) ->
  api.rooms.remove.delete(pathParams: id: _roomId)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/remove'
        data: resp
      notifyActions.success lang.getText('remove-topic-success')
      success? resp
    .catch (error) ->
      fail? error

exports.roomRemoveMember = (data, success, fail) ->
  config =
    pathParams:
      id: data._roomId
    data:
      _userId: data._userId
  api.rooms.removemember.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/remove-member'
        data: data
      notifyActions.success lang.getText('topic-remove-member-success')
      success? resp
    .catch (error) ->
      fail? error

exports.roomArchive = (_roomId, isArchived, success, fail) ->
  config =
    pathParams:
      id: _roomId
    data:
      isArchived: isArchived
  api.rooms.archive.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/archive'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.roomUpdate = (_roomId, data, success, fail) ->
  config =
    pathParams:
      id: _roomId
    data: data
  api.rooms.update.put(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.roomUpdateGuest = (_roomId, enabled, success, fail) ->
  config =
    pathParams:
      id: _roomId
    data:
      isGuestEnabled: enabled
  api.rooms.guest.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.create = (data, success, fail) ->
  config =
    data: data

  api.rooms.create.post config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/create'
        data: resp
      notifyActions.success lang.getText('create-topic-success')
      success? resp
    .catch (error) ->
      fail? error
