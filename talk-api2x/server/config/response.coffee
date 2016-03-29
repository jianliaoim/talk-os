Err = require 'err1st'
jsonMask = require 'json-mask'
_ = require 'lodash'
socket = require '../components/socket'
logger = require '../components/logger'

app = require '../server'

res = app.response

res.response = ->
  {err, result, req} = this
  if err
    err = new Err(err) unless err instanceof Err
    if err.code is 100  # Log the unknown error
      logger.err req.method, req.url, Object.keys(req.headers), Object.keys(req.query), Object.keys(req.body), err.stack
    @status(err.status or 400).json
      code: err.code
      message: err.locale(req.getLocale()).message
  else
    result = result?.toJSON?() or result
    if @req.query?.fields and toString.call(result) in ['[object Object]', '[object Array]']
      result = jsonMask(result, @req.query?.fields) or undefined
    if @req.query?.excludeFields and toString.call(result) is '[object Object]'
      result = _.omit(result, @req.query.excludeFields.split(','))
    @status(200).send(result)

res.broadcast = (channel, event, data, callback) ->
  socket.broadcast channel, event, data, @req.get('socketId'), callback

res.publish = (channel, event, data, callback) ->
  socket.broadcast channel, event, data, null, callback

res.join = (channel, callback) ->
  socket.join channel, @req.get('socketId'), callback

res.leave = (channel, callback) ->
  socket.leave channel, @req.get('socketId'), callback
