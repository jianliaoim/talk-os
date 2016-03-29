
api     = require '../network/api'

TALK = require '../config'
searchActions = require './search'
dispatcher = require '../dispatcher'

apiHost = TALK.apiHost

# expose methods

exports.createTag = (_teamId, name, success, fail) ->
  data =
    _teamId: _teamId
    name: name
  api.tags.create.post(data: data)
    .then (resp) ->
      dispatcher.handleViewAction type: 'tag/create', data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.removeTag = (_tagId, success, fail) ->
  api.tags.remove.delete(pathParams: id: _tagId)
    .then (resp) ->
      dispatcher.handleViewAction type: 'tag/remove', data: resp
    .catch (error) ->
      fail? error

exports.readTag = (_teamId, success, fail) ->
  api.tags.read.get(queryParams: {_teamId})
    .then (resp) ->
      dispatcher.handleViewAction type: 'tag/read', data:
        _teamId: _teamId
        tags: resp
      success? resp
    .catch (error) ->
      fail? error

exports.updateTag = (_id, name, success, fail) ->
  config =
    pathParams:
      id: _id
    data:
      name: name
  api.tags.update.put(config)
    .then (resp) ->
      dispatcher.handleViewAction type: 'tag/update', data: resp
    .catch (error) ->
      fail? error

exports.searchTagged = (data, success, fail) ->
  readResults = (resp) ->
    dispatcher.handleViewAction
      type: 'tagged-result/read'
      data: resp
    success? resp
  searchActions.collection(data, readResults, fail)

exports.clearResults = ->
  dispatcher.handleViewAction type: 'tagged-result/clear'
