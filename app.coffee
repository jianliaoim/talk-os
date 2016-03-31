express = require 'express'
config = require 'config'
logger = require('graceful-logger').format 'medium'

app = express()

# Account api and front-end
accountApp = require './talk-account/server/server'
app.use '/account', accountApp
logger.info 'Account initialized'

# Api
apiApp = require './talk-api2x/server/server'
app.use '/v2', apiApp
logger.info "Api initialized"

# Front-end assets
app.use '/', express.static("#{__dirname}/talk-web/build")
app.use '/', express.static("#{__dirname}/talk-account/build")

# Front-end index
app.use '/', (req, res, next) -> res.sendFile "#{__dirname}/talk-web/build/index.html"

port = process.env.PORT or config.port
server = app.listen port, -> logger.info "Talk listen on #{port}"

# Websocket
snapperInitializer = require './talk-snapper/server/server'
snapperInitializer server
logger.info 'Snapper initialized'
