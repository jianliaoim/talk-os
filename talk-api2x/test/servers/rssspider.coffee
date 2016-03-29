express = require 'express'

module.exports = app = express()

app.use '/', (req, res, next) -> res.end 'ok'
