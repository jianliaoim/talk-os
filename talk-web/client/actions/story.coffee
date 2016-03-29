assign = require 'object-assign'
recorder = require 'actions-recorder'

TALK = require '../talk'
query = require '../query'
dispatcher = require '../dispatcher'

notifyActions = require '../actions/notify'
routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

api = require '../network/api'

exports.create = (data, success, error) ->
  api.stories.create.post {data: data}
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'story/create'
        data: resp
      routerHandlers.story data._teamId, resp._id
      success?()
    .catch (error) ->
      error?()
      notifyActions.error '创建story失败'

exports.leave = (_teamId, _storyId) ->
  config =
    pathParams:
      id: _storyId

  routerHandlers.team _teamId
  api.stories.leave.post(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'story/leave'
        data: resp
    .catch (error) ->
      notifyActions.error '退出story失败'

exports.join = (_storyId) ->
  config =
    pathParams:
      id: _storyId

  api.stories.join.post config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'story/join'
        data: resp
    .catch (error) ->
      notifyActions.error '加入story失败'

exports.read = (_teamId, { maxDate }, success, fail) ->
  config =
    queryParams: assign {},
      { _teamId }
      { maxDate } if maxDate?

  api.stories.read.get config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'story/read'
        data:
          _teamId: _teamId
          data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.readone = (_storyId, success, fail) ->
  config = pathParams: id: _storyId

  api.stories.readone.get config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'story/readone'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.remove = (_teamId, _channelId) ->
  config = pathParams: id: _channelId

  routerHandlers.team _teamId
  api.stories.remove.delete config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'story/remove'
        data: resp
    .catch (error) ->
      notifyActions.error '删除story失败'

exports.update = (_storyId, data, success, fail) ->
  config =
    pathParams:
      id: _storyId
    data: data

  api.stories.update.put config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'story/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error
      notifyActions.error '更新story失败'

# Action of create story draft, insert draft data,
# dispatch 'story/create-draft' into updater.
#
# @param { String } _teamId
# @param { String } _draftStoryId
# @param { String } draftStoryCategory
#
# @return null

exports.createDraft = (_teamId, _draftStoryId, draftStoryCategory) ->
  dispatcher.handleViewAction
    type: 'story/create-draft'
    data: { _teamId, _id: _draftStoryId, category: draftStoryCategory }
