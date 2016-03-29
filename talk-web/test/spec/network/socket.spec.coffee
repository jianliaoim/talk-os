describe 'socket', ->

  networkHandler = null

  beforeEach ->
    require 'config'
    @TALK =
      'X-Socket-Id': 'x-socket-id'
      'sockHost': 'fake host'
    require.cache[require.resolve('config')].exports = @TALK

    networkHandler = require 'handlers/network'
    spyOn(networkHandler, 'newConnection')
    spyOn(networkHandler, 'longReconnection')

    @socket = require 'network/socket'
    @Primus = require 'primus-client'

    spyOn(@Primus, 'connect').and.callThrough()

  describe 'method: connect', ->
    it 'should be defined', ->
      expect(@socket.connect).toBeDefined()

    it 'should connect primus', ->
      @socket.connect()
      expect(@Primus.connect).toHaveBeenCalledWith @TALK.sockHost

    it 'should not connect primus twice', ->
      @socket.connect()
      @socket.connect()
      expect(@Primus.connect).toHaveBeenCalled()
      expect(@Primus.connect.calls.count()).toBe 1

  describe 'listeners', ->
    primus = firstConnectionCB = null

    beforeEach ->
      firstConnectionCB = jasmine.createSpy 'cb'
      spyOn(@socket, 'emit')
      primus = @socket.connect(firstConnectionCB)

    describe 'on "reconnect scheduled" handler', ->
      it 'should broadcast disconnection if disconnected', ->
        deviceActions = require 'actions/device'
        actions = require 'actions'
        spyOn deviceActions, 'networkDisconnect'
        spyOn actions, 'outdateStore'
        primus.emit 'reconnect scheduled', {}
        expect(deviceActions.networkDisconnect).toHaveBeenCalled()
        expect(actions.outdateStore).toHaveBeenCalled()
        deviceActions.networkDisconnect.calls.reset()

    describe 'on "reconnect scheduled" handler', ->
      it 'should discconect device', ->
        deviceActions = require 'actions/device'
        actions = require 'actions'
        spyOn deviceActions, 'networkDisconnect'
        spyOn actions, 'outdateStore'
        primus.emit 'offline'
        expect(deviceActions.networkDisconnect).toHaveBeenCalled()
        expect(actions.outdateStore).toHaveBeenCalled()

    describe 'on "data" handler', ->
      describe 'handle message data', ->
        it 'should emit', ->
          socketData =
            a: 'message:create'
            d: 'data'
          primus.emit 'data', socketData
          expect(@socket.emit).toHaveBeenCalledWith socketData.a, socketData.d

      describe 'new connection', ->
        socketData = null

        beforeEach ->
          socketData =
            socketId: 'socket id'
          primus.emit 'data', socketData

        it 'should handle socket data with socketId', ->
          expect(@TALK['X-Socket-Id']).toBe socketData.socketId

        it 'should make new connection requests', ->
          expect(networkHandler.newConnection).toHaveBeenCalled()

        it 'should call firstConnectionCB', ->
          expect(firstConnectionCB).toHaveBeenCalled()

      describe 'reconnection', ->
        beforeEach ->
          primus.emit 'data', socketId: 'socket id1'

        it "should perform a new reconnection", ->
          primus.emit 'data', socketId: 'socket id2'
          expect(networkHandler.longReconnection).toHaveBeenCalled()

        it 'should clear reconnection notification after 5 seconds', ->
          notifyBannerActions = require 'actions/notify-banner'
          spyOn notifyBannerActions, 'success'
          spyOn notifyBannerActions, 'clear'
          primus.emit 'data', socketId: 'socket id2'
          expect(notifyBannerActions.success).toHaveBeenCalled()
          jasmine.clock().tick(5000)
          expect(notifyBannerActions.clear).toHaveBeenCalled()

        it 'should not call firstConnectionCB again', ->
          expect(firstConnectionCB.calls.count()).toBe 1
