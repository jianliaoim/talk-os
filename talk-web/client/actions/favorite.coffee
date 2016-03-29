Immutable = require 'immutable'

dispatcher = require '../dispatcher'
api        = require '../network/api'

lang = require '../locales/lang'

notifyActions = require '../actions/notify'

exports.createFavorite = (message, success, fail) ->
  api.favorites.create.post(data: _messageId: message.get('_id'))
    .then (resp) ->
      notifyActions.success lang.getText('message-favorited')
      dispatcher.handleViewAction type: 'favorite/create', data: resp
      success? Immutable.fromJS(resp)
    .catch (error) ->
      notifyActions.error lang.getText('message-favorited-failed')
      fail? error

exports.readFavorite = (_teamId, success, fail) ->
  api.favorites.read.get(queryParams: _teamId: _teamId)
    .then (resp) ->
      dispatcher.handleViewAction type: 'favorite/read', data: resp
      success? Immutable.fromJS(resp)
    .catch (error) ->
      fail? error

exports.removeFavorite = (_messageId, success, fail) ->
  api.favorites.remove.delete(pathParams: id: _messageId)
    .then (resp) ->
      notifyActions.success lang.getText('favorite-cancelled')
      dispatcher.handleViewAction type: 'favorite/remove', data: resp
      success? Immutable.fromJS(resp)
    .catch (error) ->
      notifyActions.success lang.getText('favorite-cancelled-failed')
      fail? error

exports.searchFavorite = (data, success, fail) ->
  api.favorites.search.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction type: 'fav-result/read', data: resp.favorites
      success? Immutable.fromJS(resp)
    .catch (error) ->
      fail? error

exports.clearResults = ->
  dispatcher.handleViewAction type: 'fav-result/clear'
