config = require 'config'
express = require 'express'
_ = require 'lodash'
Primus = require 'primus'
io = require './io'

logger = require('graceful-logger').format 'medium'

app = express()

port = process.env.PORT or config.port

server = app.listen port, -> logger.info "Snapper server listen on #{port}"

primus = new Primus server,
  transformer: 'engine.io'
  pathname: config.prefix
  timeout: 50000

primus.authorize require './auth'

primus.on 'connection', (client) ->
  logger.info "Connected #{client.id}"
  io.add client
  client.write socketId: client.id

primus.on 'disconnection', (client) ->
  logger.info "Closed #{client.id}"
  io.remove client.id

module.exports = server
