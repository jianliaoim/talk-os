# Fake tps server
express = require 'express'

# TPS
module.exports = app = express()

app.post '/channels/subscribe', (req, res) ->
  req.body.should.have.properties 'channelKey', 'userId'
  res.json channelId: 'xxx'

app.post '/channels/unsubscribe', (req, res) -> res.json ok: 1

app.post '/messages/broadcast', (req, res) ->
  req.body.should.have.properties 'channelKey', 'payload', 'appKey', 'appSecret'
  res.json _id: '1'
