express = require 'express'
config = require 'config'
logger = require('graceful-logger').format 'medium'

app = express()

# accountApp = require './talk-account/server/server'
# app.use '/account', accountApp
# logger.info 'Account initialized'
#
# # snapperApp = require './talk-snapper/server/server'
# # app.use '/snapper', snapperApp
#
# apiApp = require './talk-api2x/server/server'
# app.use '/', apiApp
# logger.info "Api initialized"

# Front-end assets
app.use '/', express.static("#{__dirname}/talk-web/build")
app.use '/', express.static("#{__dirname}/talk-account/build")

# Front-end index
app.use '/', (req, res, next) -> res.sendFile "#{__dirname}/talk-web/build/index.html"

port = process.env.PORT or config.port
app.listen port, -> logger.info "Talk listen on #{port}"
