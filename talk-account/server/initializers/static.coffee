path = require 'path'
express = require 'express'

app = require '../server'

staticPath =
  switch app.get 'env'
    when 'dev'
      path.join __dirname, '../../client'
    when 'development', 'ws'
      path.join __dirname, '../../build'

app.use '/build', express.static staticPath if staticPath
