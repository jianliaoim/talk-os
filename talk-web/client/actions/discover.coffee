dispatcher = require '../dispatcher'

api = require '../network/api'

# http://talk.ci/doc/restful/discover.urlmeta.html
exports.urlmeta = (url, success, fail) ->
  config = queryParams: { url }

  api.discover.urlmeta.get config
    .then (resp) ->
      success? resp
    .catch (error) ->
      fail? error
