request = require 'request'
_ = require 'lodash'
Promise = require 'bluebird'
config = require 'config'
Err = require 'err1st'
requestAsync = Promise.promisify request
logger = require 'graceful-logger'

tps = module.exports

_handleCallback = (callback = ->) ->

  _callback = (err, res, data) ->
    if res?.statusCode is 200
      callback err, data
    else
      err or= new Err "PUSH_FAILED", data.message
      callback err

tps.subscribe = (channelKey, userId, callback = ->) ->
  return callback(new Err('CONFIG_MISSING', 'tps')) unless config.tps

  options =
    method: 'POST'
    url: config.tps.apiHost + '/channels/subscribe'
    json: true
    headers:
      'x-app-key': config.tps.appKey
      'x-app-secret': config.tps.appSecret
    body:
      channelKey: channelKey
      userId: userId

  request options, _handleCallback(callback)

tps.unsubscribe = (channelKey, userId, callback = ->) ->
  return callback(new Err('CONFIG_MISSING', 'tps')) unless config.tps

  options =
    method: 'POST'
    url: config.tps.apiHost + '/channels/unsubscribe'
    json: true
    headers:
      'x-app-key': config.tps.appKey
      'x-app-secret': config.tps.appSecret
    body:
      channelKey: channelKey
      userId: userId

  request options, _handleCallback(callback)

bulk =
  payloads: []

tpsOptions =
  max: 100
  interval: 1000
  timer: null
  cleared: true

_broadcastBulk = ->
  # Clear timer
  clearTimeout tpsOptions.timer
  tpsOptions.cleared = true

  return unless bulk.payloads.length

  options =
    method: 'POST'
    url: config.tps.apiHost + '/messages/bulk'
    headers:
      'x-app-key': config.tps.appKey
      'x-app-secret': config.tps.appSecret
    json: true
    body: payloads: bulk.payloads

  # Clear bulks
  bulk.payloads = []

  requestAsync options
  .catch (err) -> logger.warn err.stack

tps.broadcast = (channelKeys, payload, bodyOptions = {}, callback = ->) ->
  return callback(new Err('CONFIG_MISSING', 'tps')) unless config.tps

  body = _.assign
    payload: payload
  , bodyOptions

  if toString.call(channelKeys) is '[object Array]'
    body.channelKeys = channelKeys
  else if toString.call(channelKeys) is '[object String]'
    body.channelKey = channelKeys
  else
    return callback(new Err('PARAMS_INVALID', 'channelKeys'))

  bulk.payloads.push body

  if bulk.payloads.length > tpsOptions.max
    _broadcastBulk()

  else if tpsOptions.cleared
    tpsOptions.timer = setTimeout _broadcastBulk, tpsOptions.interval
    tpsOptions.cleared = false

  callback()

Promise.promisifyAll tps
