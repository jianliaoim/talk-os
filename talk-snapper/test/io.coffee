# Test For IO component

path = require 'path'
_ = require 'lodash'
eio = require 'engine.io-client'
should = require 'should'
config = require 'config'

io = require '../server/io'

describe 'IO', ->

  client = null
  socketId = null

  describe 'IO#Add', ->

    it 'should add client to io when client connected', (done) ->
      client = new eio.Socket "ws://localhost:#{config.port}", path: config.prefix

      client.onMessage = ->

      client.on 'message', (data) ->
        try
          data = JSON.parse(data)
          client.onMessage data
          if data.socketId
            socketId = data.socketId
            _.keys(io.clients).length.should.eql(1)  # Connected
            return done()
        catch err
          console.error err

  describe 'IO#Join', ->

    it 'should join a client to some rooms', (done) ->
      rooms = ['r1', 'r2', 'r3']
      io.join(socketId, rooms)
      _.keys(io.rooms).length.should.eql(3)
      done()

  describe 'IO#ReceiveMessage', ->

    it 'should receive message from room', (done) ->
      client.onMessage = (data) ->
        data.should.eql 'Hello'
        done()
      io.broadcast 'r1', 'Hello'

  describe 'IO#DoNotReceiveMessage', ->

    it 'should not receive message when foreclosed', (done) ->
      client.onMessage = (data) ->
        # 不能收到消息
        should(data).eql undefined
      setTimeout done, 200
      io.broadcast 'r1', 'Hello Again', client.id

  describe 'IO#Leave', ->

    it 'should clear when client leave room', (done) ->
      io.leave(socketId, 'r1')
      _.keys(io.rooms).length.should.eql(2)
      done()

  describe 'IO#Remove', ->

    it 'should clear rooms and clients when client closed', (done) ->
      client.close()
      setTimeout ->
        _.keys(io.clients).length.should.eql(0)
        _.keys(io.rooms).length.should.eql(0)
        done()
      , 200
