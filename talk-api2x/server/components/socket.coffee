crypto = require 'crypto'
redis = require 'redis'
config = require 'config'
Promise = require 'bluebird'
jwt = require 'jsonwebtoken'
tps = require './tps'

client = redis.createClient.apply redis, config.snapper.pub

_getChannels = (channel, event, data) ->
  if toString.call(channel) is '[object String]'
    channel = _talkPrefix channel
  else if toString.call(channel) is '[object Array]'
    channel = channel.map _talkPrefix
  return channel

_talkPrefix = (channel) -> "talk:#{channel}"

socket =

  join: (channel, socketId, callback = ->) ->
    channel = _talkPrefix channel
    if jwt.decode socketId
      $join = tps.subscribeAsync channel, socketId
    else
      args = {0: socketId, 1: channel}
      client.publish "#{config.snapper.channelPrefix}:join", JSON.stringify(args)
      $join = Promise.resolve ok: 1

    $join.nodeify callback

  leave: (channel, socketId, callback = ->) ->
    channel = _talkPrefix channel
    if jwt.decode socketId
      $leave = tps.unsubscribeAsync channel, socketId
    else
      args = {0: socketId, 1: channel}
      client.publish "#{config.snapper.channelPrefix}:leave", JSON.stringify(args)
      $leave = Promise.resolve ok: 1

    $leave.nodeify callback

  broadcast: (channel, event, data, socketId, callback = ->) ->
    channels = _getChannels channel
    payload = a: event, d: data, v: 2

    # Broadcast message by snapper
    args = {0: channels, 1: JSON.stringify(payload), 2: socketId}
    client.publish "#{config.snapper.channelPrefix}:broadcast", JSON.stringify(args)

    # Broadcast message by tps
    if jwt.decode socketId
      bodyOptions = ignoredUserIds: [socketId]
    else
      bodyOptions = {}

    if event and data?._id
      bodyOptions.uid = crypto.createHash('sha1').update("#{event}#{data._id}#{channels?.toString()}").digest('hex')

    $broadcast = tps.broadcastAsync channels, payload, bodyOptions

    $broadcast.nodeify callback

Promise.promisifyAll socket

module.exports = socket
