express = require 'express'
config = require 'config'
logger = require('graceful-logger').format 'medium'

apiApp = require './talk-api2x/server/server'
logger.info "Api initialized"

accountApp = require './talk-account/server/server'
logger.info 'Account initialized'

# snapperApp = require './talk-snapper/server/server'

app = express()

app.use '/account', accountApp

# app.use '/snapper', snapperApp

app.use '/', apiApp

port = process.env.PORT or config.port
app.listen port, -> logger.info "Talk listen on #{port}"
