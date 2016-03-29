request = require 'request'

options =
  method: 'POST'
  headers:
    "Content-Type": "application/json"
  url: 'http://talk.bi/v1/services/webhook/d8fb3faef5008310db00a8fa6fdd3f881e8656c4'
  json: true

[
  'commit-comment'
  'create'
  'delete'
  'fork'
  'issue-comment'
  'issues'
  'pull-request'
  'pull-request-review-comment'
  'push'
].forEach (payloadName) ->

  payload = require "../services/payloads/github-#{payloadName}"
  request payload(options), (err, res, body) -> console.log body
