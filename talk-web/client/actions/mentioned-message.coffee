assign = require 'object-assign'
recorder = require 'actions-recorder'

dispatcher = require '../dispatcher'

api = require '../network/api'

exports.MESSAGE_LIMIT = 10

###
 * 清除存储在本地缓存中的 mentioned messages 的搜索结果
###
exports.clear = (params) ->
  dispatcher.handleViewAction
    type: 'mentioned-message/clear'
    data:
      params: params

###
 * API: http://talk.ci/doc/restful/message.mentions.html
 *
 * @param {_teamId<String>, _maxId<String>}<Object> params
 * @param {Function} success
 * @param {Function} fail
 *
###
exports.read = (params, success, fail) ->
  config =
    queryParams: assign {}, params,
      { limit: exports.MESSAGE_LIMIT }

  api.messages.mentions.get config
  .then (resp) ->
    dispatcher.handleViewAction
      type: 'mentioned-message/read'
      data:
        params: params
        data: resp
    success? resp
  .catch (error) ->
    fail? error
