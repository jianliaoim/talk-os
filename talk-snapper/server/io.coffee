_ = require 'lodash'
redis = require 'redis'
config = require 'config'
logger = require 'graceful-logger'

connectedCount = 0
disconnectedCount = 0

class Io

  namespace = config.channelPrefix

  constructor: ->
    @clients = {}
    @rooms = {}
    @sub = redis.createClient.apply(redis, config.sub)
    @pub = redis.createClient.apply(redis, config.pub)
    @_subscribe()

  add: (client) ->
    connectedCount += 1
    @clients[client.id] = client
    return this

  _subscribe: ->
    @sub.on 'message', (channel, message) =>
      [prefix, method] = channel.split(':')
      try
        args = _.values(JSON.parse(message))
      catch e
        return false
      return false unless typeof @["_#{method}"] is 'function'
      @["_#{method}"].apply(this, args)

    ['send', 'remove', 'join', 'leave', 'broadcast'].forEach (method) =>
      @sub.subscribe("#{namespace}:#{method}")

  send: (id, message) ->
    unless @_send.apply(this, arguments)
      @pub.publish("#{namespace}:send", JSON.stringify(arguments))

  remove: (id) ->
    unless @_remove.apply(this, arguments)
      @pub.publish("#{namespace}:remove", JSON.stringify(arguments))

  join: (id, room) ->
    unless @_join.apply(this, arguments)
      @pub.publish("#{namespace}:join", JSON.stringify(arguments))

  leave: (id, room) ->
    unless @_leave.apply(this, arguments)
      @pub.publish("#{namespace}:leave", JSON.stringify(arguments))

  broadcast: ->
    @pub.publish("#{namespace}:broadcast", JSON.stringify(arguments))

  _remove: (id) ->
    return false unless @clients[id]
    client = @clients[id]
    rooms = if client.rooms? then _.keys(client.rooms) else []
    @_leave(id, rooms) if rooms.length > 0  # Leave all rooms before remove the client
    delete @clients[id]
    disconnectedCount += 1
    return true

  # @param `id` client id
  # @param `room` room name, or a list of room names
  _join: (id, room) ->
    return false unless @clients[id]
    client = @clients[id]

    _joinRoom = (room) =>
      # Bind room to client object
      client.rooms = {} unless client.rooms?
      client.rooms[room] = 1
      # Add client to room map
      @rooms[room] = {} unless @rooms[room]
      @rooms[room][id] = 1

    if room instanceof Array
      room.forEach(_joinRoom)
    else
      _joinRoom(room)

    return true

  _leave: (id, room) ->
    return false unless @clients[id]
    client = @clients[id]

    _leaveRoom = (room) =>
      delete client.rooms[room] if client.rooms?[room]
      delete @rooms[room][id] if @rooms[room]?[id]
      delete @rooms[room] if _.isEmpty(@rooms[room])

    if room instanceof Array
      room.forEach(_leaveRoom)
    else
      _leaveRoom(room)

    return true

  _broadcast: (room, message, id) ->
    _broadcastRoom = (room) =>
      return false unless @rooms[room]
      ids = @rooms[room]
      @clients[_id].write(message) for _id of ids when @clients[_id] and _id isnt id

    if room instanceof Array
      room.forEach(_broadcastRoom)
    else
      _broadcastRoom(room)
    return true

  _send: (id, message) ->
    return false unless @clients[id]
    @clients[id].write(message)
    return true

io = new Io

setInterval ->
  logger.info "Connected #{connectedCount}, disconnected #{disconnectedCount}, online #{Object.keys(io.clients).length}"
, 20000

module.exports = io
