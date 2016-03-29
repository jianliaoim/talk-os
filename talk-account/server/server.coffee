express = require 'express'
sundae = require 'sundae'
requireDir = require 'require-dir'

app = sundae express()

module.exports = app

# Initialize components
require './components'

# Initialize application
require './initializers/database'
require './initializers/express'
require './initializers/static'
require './initializers/request'
require './initializers/error'
# Initialize controllers
requireDir './apis', recurse: true
requireDir './pages', recurse: true
# Initialize routes
require './initializers/routes'
