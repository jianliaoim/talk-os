Immutable = require 'immutable'

describe 'Handlers: network', ->
  beforeEach ->
    @networkHandler = require 'handlers/network'
    @api = require 'network/api'
    @recorder = require 'actions-recorder'

  describe 'Method: newConnection', ->
    it 'should subscribe to users', ->
      spyOn(@api.users.subscribe, 'post')
      @networkHandler.newConnection()
      expect(@api.users.subscribe.post).toHaveBeenCalled()

  describe 'Method: longReconnection', ->
    store = userActions = teamActions = messageActions = roomActions = init = null

    beforeEach ->
      init = (_store) =>
        store = _store
        userActions = require 'actions/user'
        teamActions = require 'actions/team'
        messageActions = require 'actions/message'
        roomActions = require 'actions/room'
        spyOn(@recorder, 'getState').and.returnValue Immutable.fromJS(_store)
        spyOn(userActions, 'userMe')
        spyOn(teamActions, 'teamsFetch')
        spyOn(roomActions, 'fetch')
        spyOn(messageActions, 'messageReadChat')
        @networkHandler.longReconnection()

    describe 'common', ->
      beforeEach ->
        init
          router:
            data:
              _teamId: 'team id'
              _roomId: 'room id'

      it 'should update users', ->
        expect(userActions.userMe).toHaveBeenCalled()

      it 'should update teams', ->
        expect(teamActions.teamsFetch).toHaveBeenCalled()

    describe 'in room', ->
      beforeEach ->
        init
          router:
            data:
              _teamId: 'team id'
              _roomId: 'room id'

      it 'should get messages for current room', ->
        expect(roomActions.fetch).toHaveBeenCalledWith store.router.data._roomId
        expect(messageActions.messageReadChat).not.toHaveBeenCalled()

    describe 'in chat', ->
      beforeEach ->
        init
          router:
            data:
              _teamId: 'team id'
              _toId: 'to id'

      it 'should get messages for current chat', ->
        _teamId = store.router.data._teamId
        _toId = store.router.data._toId
        expect(messageActions.messageReadChat).toHaveBeenCalledWith _teamId, _toId
        expect(roomActions.fetch).not.toHaveBeenCalled()
