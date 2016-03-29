app = require './server/server'
logger = require 'graceful-logger'
port = process.env.PORT or 7001

app.listen port, -> logger.info "Server listen on #{port}"
