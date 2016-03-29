express = require 'express'
sundae = require 'sundae'
requireDir = require 'require-dir'

module.exports = app = sundae express()

# Initialize components
require './components'
# Initialize services
require './service'
# Initialize observers
requireDir './observers'
# Load controllers
requireDir './controllers', recurse: true
# Apply internal services initializers
requireDir './services'

# Config application
require './config/express'
require './config/error'
require './config/request'
require './config/response'
require './config/routes'
