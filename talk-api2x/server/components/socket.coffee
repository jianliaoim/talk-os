crypto = require 'crypto'
redis = require 'redis'
config = require 'config'
Promise = require 'bluebird'
jwt = require 'jsonwebtoken'

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
    args = {0: socketId, 1: channel}
    client.publish "#{config.snapper.channelPrefix}:join", JSON.stringify(args)
    callback()

  leave: (channel, socketId, callback = ->) ->
    channel = _talkPrefix channel
    args = {0: socketId, 1: channel}
    client.publish "#{config.snapper.channelPrefix}:leave", JSON.stringify(args)
    callback()

  broadcast: (channel, event, data, socketId, callback = ->) ->
    channels = _getChannels channel
    payload = a: event, d: data, v: 2

    # Broadcast message by snapper
    args = {0: channels, 1: JSON.stringify(payload), 2: socketId}
    client.publish "#{config.snapper.channelPrefix}:broadcast", JSON.stringify(args)
    callback()

Promise.promisifyAll socket

module.exports = socket
