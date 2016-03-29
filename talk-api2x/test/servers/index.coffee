express = require 'express'
bodyParser = require 'body-parser'

module.exports = app = express()

app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)

app.use '/account', require './account'
app.use '/teambition', require './teambition'
app.use '/tps', require './tps'
app.use '/striker', require './striker'
app.use '/outgoing', require './outgoing'
app.use '/talkai', require './talkai'
app.use '/rssspider', require './rssspider'
app.use '/rly', require './rly'

app.use (err, req, res, next) ->
  res.status(400).json
    code: 400
    message: err.message

app.use (err, req, res, next) ->
  res.status(500).json
    code: err.code
    message: err.message
    stack: err.stack

app.listen 7632
