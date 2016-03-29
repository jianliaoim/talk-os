request = require 'request'

options =
  method: 'POST'
  headers:
    "Content-Type": "application/json"
  url: 'http://talk.bi/v1/services/webhook/9f16d5cfe7f850d7365fffb8eef6a409f568ea9c'

[
  'push'
  'issues'
  'merge-request'
].forEach (payloadName) ->
  payload = require "../services/payloads/gitlab-#{payloadName}"
  request payload(options), (err, res, body) -> console.log body
