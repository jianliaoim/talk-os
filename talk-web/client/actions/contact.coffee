dispatcher = require '../dispatcher'

api = require '../network/api'

exports.contactRemove = (_teamId, user, success, fail) ->
  config =
    pathParams:
      id: _teamId
    data:
      _userId: user.get('_id')
  api.teams.removemember.post(config)
    .then (resp) ->
      dispatcher.handleViewAction type: 'contact/remove', data: {_teamId, user}
      success? resp
    .catch (error) ->
      fail? error

exports.contactUpdateRole = (_teamId, _userId, role, success, fail) ->
  config =
    pathParams:
      id: _teamId
    data:
      _userId: _userId
      role: role
  api.teams.setmemberrole.post(config)
    .then (resp) ->
      dispatcher.handleViewAction type: 'contact/update', data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.fetchLeftContacts = (_teamId, success, fail) ->
  config =
    pathParams:
      id: _teamId
    queryParams:
      isQuit: true
  api.teams.members.get(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'contact/fetch-left'
        data: {_teamId, data: resp}
      success? resp
    .catch (error) ->
      fail? error

# api: teams.members.get
# http://talk.ci/doc/restful/team.members.html
exports.read = (_teamId, success, fail) ->
  config =
    pathParams:
      id: _teamId

  api.teams.members.get config
  .then (resp) ->
    dispatcher.handleViewAction
      type: 'contact/read'
      data:
        _teamId: _teamId
        data: resp
    success? resp
  .catch (error) ->
    fail? error
