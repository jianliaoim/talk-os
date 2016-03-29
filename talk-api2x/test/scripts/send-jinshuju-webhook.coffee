request = require 'request'

options =
  method: 'POST'
  headers:
    "Content-Type": "application/json"
  url: 'http://talk.bi/v1/services/webhook/b443cb1660f15fad9b3e0de8c2c29f1a11701a82'

[
  'data'
].forEach (payloadName) ->
  payload = require "../services/payloads/jinshuju-#{payloadName}"
  request payload(options), (err, res, body) -> console.log body
