Immutable = require 'immutable'

describe 'Handlers: router', ->

  beforeEach ->
    @routerHandler = require 'handlers/router'

  describe 'Method: changeChannel', ->
    _teamId = _roomId = _toId = null

    beforeEach ->
      _teamId = '_teamId'
      _roomId = undefined
      _toId = undefined

      spyOn(@routerHandler, 'room')
      spyOn(@routerHandler, 'chat')
      spyOn(@routerHandler, 'team')

    it 'should goto room page if _roomId is defined', ->
      _roomId = '_roomId'
      @routerHandler.changeChannel(_teamId, _roomId, _toId)
      expect(@routerHandler.room).toHaveBeenCalledWith _teamId, _roomId, {}
      expect(@routerHandler.chat).not.toHaveBeenCalled()
      expect(@routerHandler.team).not.toHaveBeenCalled()

    it 'should goto chat page if _toId is defined', ->
      _toId = '_toId'
      @routerHandler.changeChannel(_teamId, _roomId, _toId)
      expect(@routerHandler.room).not.toHaveBeenCalled()
      expect(@routerHandler.chat).toHaveBeenCalledWith _teamId, _toId, {}
      expect(@routerHandler.team).not.toHaveBeenCalled()

    it 'should goto team page if _teamId is defined but not _roomId nor _toId', ->
      @routerHandler.changeChannel(_teamId, _roomId, _toId)
      expect(@routerHandler.room).not.toHaveBeenCalled()
      expect(@routerHandler.chat).not.toHaveBeenCalled()
      expect(@routerHandler.team).toHaveBeenCalledWith _teamId

    it 'should provide search query to room', ->
      searchQuery = {search: 'id'}
      _roomId = '_roomId'
      @routerHandler.changeChannel(_teamId, _roomId, _toId, searchQuery)
      expect(@routerHandler.room).toHaveBeenCalledWith _teamId, _roomId, searchQuery

    it 'should provide search query to chat', ->
      searchQuery = {search: 'id'}
      _toId = '_toId'
      @routerHandler.changeChannel(_teamId, _roomId, _toId, searchQuery)
      expect(@routerHandler.chat).toHaveBeenCalledWith _teamId, _toId, searchQuery
