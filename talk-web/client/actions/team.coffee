Immutable = require 'immutable'
recorder = require 'actions-recorder'

dispatcher = require '../dispatcher'

lang = require '../locales/lang'
notifyActions = require '../actions/notify'
api = require '../network/api'

exports.teamSubscribe = (_teamId, success, fail) ->
  api.teams.subscribe.post(pathParams: id: _teamId)
    .then (resp) ->
      recorder.dispatch 'team/subscribed',
        _teamId: _teamId
      success? resp
    .catch (error) ->
      fail? error

exports.teamUnsubscribe = (teamId, success, fail) ->
  api.teams.unsubscribe.post(pathParams: id: teamId)
    .then (resp) ->
      success? resp
    .catch (error) ->
      fail? error

exports.teamInvite = (_teamId, data, success, fail) ->
  config =
    pathParams:
      id: _teamId
    data: data
  api.teams.invite.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/join'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.removeInvite = (_id, success) ->
  config =
    pathParams:
      id: _id
  api.invitations.remove.delete(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/remove-invite'
        data: resp
      success? resp

exports.teamInvitations = (_teamId, success, fail) ->
  config =
    queryParams:
      _teamId: _teamId
  api.invitations.read.get(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/invitations'
        data:
          _teamId: _teamId
          data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.batchInvite = (_teamId, data, success, fail) ->
  config =
    pathParams:
      id: _teamId
    data: data
  api.teams.batchinvite.post(config)
    .then (resp) ->
      resp.forEach (contact) ->
        dispatcher.handleViewAction
          type: 'team/join'
          data: contact
      success? resp
    .catch (error) ->
      fail? error

exports.teamUpdate = (_teamId, data, success, fail) ->
  config =
    pathParams:
      id: _teamId
    data: data
  api.teams.update.put(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.teamLeave = (_teamId, data, success, fail) ->
  api.teams.leave.post(pathParams: id: _teamId)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/leave'
        data: data
      success? resp
    .catch (error) ->
      fail? error

exports.teamCreate = (name, success, fail) ->
  api.teams.create.post(data: name: name)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/create'
        data: resp
      success? Immutable.fromJS(resp)
    .catch (error) ->
      fail? error

exports.teamsFetch = (success, fail) ->
  api.teams.read.get()
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/fetch'
        data: resp
      success? resp
    .catch (error) ->
      console.error 'fetch team:', error
      fail? error

exports.getArchivedTopics = (_teamId, success, fail) ->
  config =
    pathParams:
      id: _teamId
    queryParams:
      isArchived: true
  api.teams.rooms.get(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'topic/reset-archived'
        data: {_teamId, data: resp}
      success? resp
    .catch (error) ->
      fail? error

exports.resetInviteUrl = (_teamId, success, fail) ->
  config =
    pathParams:
      id: _teamId
    data:
      properties:
        inviteCode: 1
  api.teams.refresh.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/update'
        data: resp
      notifyActions.success lang.getText('invite-url-reset')
      success? resp
    .catch (error) ->
      fail? error

exports.sync = (refer, success, fail) ->
  config =
    data:
      refer: refer
  api.teams.sync.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/sync'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

# teams.members.get
# http://talk.ci/doc/restful/team.members.html
exports.members = (_teamId, success, fail) ->
  config =
    pathParams:
      id: _teamId

  api.teams.members.get config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/members'
        data:
          _teamId: _teamId
          data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.syncOne = (data, success, fail) ->
  config =
    data: data
  api.teams.syncone.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/sync-one'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.getThirds = (refer, success, fail) ->
  config =
    queryParams:
      refer: refer
  api.teams.thirds.get(config)
    .then (resp) ->
      data =
        refer: refer
        teams: resp
      dispatcher.handleViewAction
        type: 'team/thirds'
        data: data
      success? data
    .catch (error) ->
      fail? error

# api: teams.rooms.get
# http://talk.ci/doc/restful/team.rooms.html
exports.teamTopics = (_teamId, success, fail) ->
  config =
    pathParams:
      id: _teamId

  api.teams.rooms.get config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/topics'
        data:
          _teamId: _teamId
          data: resp
      success? resp
    .catch (error) ->
      fail? error

# api: teams.members.get
# http://talk.ci/doc/restful/team.members.html
exports.teamMembers = (_teamId, success, fail) ->
  config =
    pathParams:
      id: _teamId

  api.teams.members.get config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'team/members'
        data:
          _teamId: _teamId
          data: resp
      success? resp
    .catch (error) ->
      fail? error
