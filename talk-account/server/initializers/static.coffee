path = require 'path'
express = require 'express'

app = require '../server'

staticPath = path.join __dirname, '../../build'

app.use '/build', express.static staticPath if staticPath
