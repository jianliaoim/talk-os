notifyActions = require '../actions/notify'
dispatcher = require '../dispatcher'
assign = require 'object-assign'
Immutable = require 'immutable'
api = require '../network/api'
util = require '../util/util'

exports.query = (_teamId, q, page, success, fail) ->
  config =
    queryParams:
      _teamId: _teamId
      q: q
      page: page
  api.messages.search.get(config)
    .then (resp) ->
      success? resp
    .catch (error) ->
      fail? error

exports.collection = (data, success, fail) ->
  if not data.q and data.hasTag
    dataFormat = [ '_teamId', 'q', 'isDirectMessage', '_creatorId', '_roomId', '_tagId', '_maxId', 'timeRange']
    config =
      queryParams: assign util.formatObject(data, dataFormat), { limit: 10 }
    api.messages.tags.get(config)
      .then (resp) ->
        resp =
          messages: resp
        success? Immutable.fromJS(resp)
      .catch (error) ->
        fail? error
  else
    dataFormat = [
      '_teamId', '_roomId', '_creatorId', '_creatorIds',
      'type', 'fileCategory', 'q', 'page', 'sort',
      'isDirectMessage', '_tagId', 'hasTag', '_storyId', 'timeRange'
    ]
    data = util.formatObject(data, dataFormat)
    api.messages.search.post(data: data)
      .then (resp) ->
        success? Immutable.fromJS(resp)
      .catch (error) ->
        fail? error

exports.collectionFile = (data, success, fail) ->
  data.type = 'file'
  api.messages.search.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'collection/file'
        data:
          messages: resp.messages
          data: data
      success? resp
    .catch (error) ->
      fail? error

exports.collectionPost = (data, success, fail) ->
  data.type = 'rtf'
  api.messages.search.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'collection/post'
        data:
          messages: resp.messages
          data: data
      success? resp
    .catch (error) ->
      fail? error

exports.collectionLink = (data, success, fail) ->
  data.type = 'url'
  api.messages.search.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'collection/link'
        data:
          messages: resp.messages
          data: data
      success? resp
    .catch (error) ->
      fail? error

exports.collectionSnippet = (data, success, fail) ->
  data.type = 'snippet'
  api.messages.search.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'collection/snippet'
        data:
          messages: resp.messages
          data: data
      success? resp
    .catch (error) ->
      fail? error

exports.messageTagged = (data, success, fail) ->
  api.messages.search.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'tagged-message/read'
        data: resp.messages
      success? resp
    .catch (error) ->
      fail? error

exports.story = (data, success, fail) ->
  api.stories.search.post(data: data)
    .then (resp) ->
      success? resp
    .catch (error) ->
      fail? error
