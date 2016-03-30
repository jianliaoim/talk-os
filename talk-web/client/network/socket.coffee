EventEmitter = require 'wolfy87-eventemitter'
Immutable = require 'immutable'

if typeof window isnt 'undefined'
  Primus = require '../vendor/primus'

config = require '../config'

actions = require '../actions'
deviceActions = require '../actions/device'
unreadHandlers = require '../handlers/unread'
networkHandler = require '../handlers/network'
notifyBannerActions = require '../actions/notify-banner'

lang = require '../locales/lang'
dev = require '../util/dev'
type = require '../util/type'
time = require '../util/time'

sockHost = config.sockHost
eventChannel = new EventEmitter
primusInstance = null

eventChannel.connect = (cb = ->) ->
  return if primusInstance

  primusInstance = Primus.connect(sockHost)

  primusInstance
    .on 'open', ->
      dev.info 'Primus connection opened'

    .on 'data', (rawObject) ->
      handleData rawObject, cb

    .on 'error', (err) ->
      dev.error 'Primus error: ', err.stack

    .on 'reconnect scheduled', (opts) ->
      deviceActions.networkDisconnect()
      notifyBannerActions.warn lang.getText('websocket-reconnect')
      actions.outdateStore()
      dev.info 'Primus reconnecting in %d ms, this is attempt %d out of %d', opts.scheduled, opts.attempt, opts.retries

    .on 'reconnected', (opts) ->
      dev.info 'Primus reconnected, took %d ms', opts.duration

    .on 'reconnect timeout', (err) ->
      dev.warn 'Primus timeout expired: %s', err.message

    .on 'reconnect failed', (err) ->
      dev.warn 'Primus reconnection failed: %s', err.message

    .on 'offline', ->
      deviceActions.networkDisconnect()
      actions.outdateStore()

    .on 'close', ->
      notifyBannerActions.error lang.getText('websocket-end')
      dev.warn 'Primus connection closed'

  primusInstance

handleData = (rawObject, cb) ->
  if type.isString(rawObject)
    try
      parsedObject = JSON.parse rawObject
    catch err
      return
  else
    parsedObject = rawObject

  if parsedObject.socketId
    newConnection(parsedObject.socketId, cb)
  else
    # a: action, d: data
    eventChannel.emit(parsedObject.a, parsedObject.d)

isFirstConnection = true
newConnection = (socketId, cb) ->
  config['X-Socket-Id'] = socketId
  networkHandler.newConnection()

  if isFirstConnection
    cb()
  else
    notifyBannerActions.success lang.getText('connected')
    time.delay 5000, notifyBannerActions.clear

    if not config.isGuest
      networkHandler.longReconnection ->
        unreadHandlers.simulateRead()

  deviceActions.networkReload()
  isFirstConnection = false

module.exports = eventChannel
