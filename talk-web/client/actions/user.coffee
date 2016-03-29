TALK = require '../config'
actions = require '../actions'
eventBus = require '../event-bus'
dispatcher = require '../dispatcher'

notifyActions = require './notify'

lang = require '../locales/lang'

api = require '../network/api'

exports.userSignout = (success, fail) ->
  api.users.signout.post()
    .then (resp) ->
      actions.markLogin false
      location.replace TALK.logoutUrl
      success? resp
    .catch (error) ->
      fail? error

exports.userMe = (success, fail) ->
  api.users.me.get()
    .then (resp) ->
      if resp?
        dispatcher.handleViewAction
          type: 'user/me'
          data: resp
        actions.markLogin true
        eventBus.emit 'fullstory', resp
      success? resp
    .catch (error) ->
      dispatcher.handleViewAction
        type: 'user/me'
        data: null
      actions.markLogin false
      console.error error
      fail? error

exports.userUpdate = (_userId, data, success, fail) ->
  config =
    pathParams:
      id: _userId
    data: data
  api.users.update.put(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'user/update'
        data: resp
      success? resp
    .catch (error) ->
      notifyActions.error (error.responseJSON?.message or 'error')
      fail? error

exports.state = (_teamId, success, fail) ->
  config =
    queryParams:
      _teamId: _teamId
      scope: 'version,checkfornewnotice,unread'
  api.state.get(config)
    .then (resp) ->
      if resp.unread?
        dispatcher.handleViewAction
          type: 'unread/check'
          data: {_teamId, data: resp.unread}
      success? resp
    .catch (error) ->
      fail? error
