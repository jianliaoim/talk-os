dispatcher = require '../dispatcher'

api = require '../network/api'

exports.search = (data, success, fail) ->
  api.messages.read.get(queryParams: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'search-message/search'
        data: resp
      success? resp
    .catch (error) ->
      console.error 'search-message.search', error
      fail? error

exports.before = (data, success, fail) ->
  api.messages.read.get(queryParams: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'search-message/before'
        data: resp
      success? resp
    .catch (error) ->
      console.error 'search-message.before', error
      fail? error

exports.after = (data, success, fail) ->
  api.messages.read.get(queryParams: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'search-message/after'
        data: resp
      success? resp
    .catch (error) ->
      console.error 'search-message.after', error
      fail? error
