xdescribe 'Actions: room', ->

  beforeEach ->
    @action = require 'actions/room'
    @api = require 'network/api'

  describe 'Method: fetch', ->
    it 'should call api', ->
      userStore = require 'store/user'
      spyOn(userStore, 'get').and.returnValue {}
      spyOn(@api.rooms.readone, 'get').and.callThrough()

      roomId = 1
      config =
        pathParams:
          id: roomId

      @action.fetch(roomId)
      expect(@api.rooms.readone.get).toHaveBeenCalledWith config

  describe 'Method: roomJoin', ->
    it 'should call api', ->
      userStore = require 'store/user'
      spyOn(userStore, 'get').and.returnValue {}
      spyOn(@api.rooms.join, 'post').and.callThrough()

      roomId = 1
      config =
        pathParams:
          id: roomId

      @action.roomJoin(roomId)
      expect(@api.rooms.join.post).toHaveBeenCalledWith config

  describe 'Method: roomLeave', ->
    it 'should call api', ->
      userStore = require 'store/user'
      spyOn(userStore, 'get').and.returnValue {}
      spyOn(@api.rooms.leave, 'post').and.callThrough()

      roomId = 1
      config =
        pathParams:
          id: roomId

      @action.roomLeave(roomId)
      expect(@api.rooms.leave.post).toHaveBeenCalledWith config

  describe 'Method: roomInvite', ->
    it 'should call api with email', ->
      spyOn(@api.rooms.invite, 'post').and.callThrough()

      roomId = 1
      email = 'test@example.com'
      config =
        pathParams:
          id: roomId
        data:
          email: email

      @action.roomInvite(roomId, email)
      expect(@api.rooms.invite.post).toHaveBeenCalledWith config

    it 'should call api with userId', ->
      spyOn(@api.rooms.invite, 'post').and.callThrough()

      roomId = 1
      userId = '123'
      config =
        pathParams:
          id: roomId
        data:
          _userId: userId

      @action.roomInvite(roomId, userId)
      expect(@api.rooms.invite.post).toHaveBeenCalledWith config

  describe 'Method: roomCreate', ->
    it 'should call api', ->
      spyOn(@api.rooms.create, 'post').and.callThrough()

      data = {}
      config = data: data

      @action.roomCreate(data)
      expect(@api.rooms.create.post).toHaveBeenCalledWith config

  describe 'Method: roomRemove', ->
    it 'should call api', ->
      spyOn(@api.rooms.remove, 'delete').and.callThrough()

      roomId = 1
      config =
        pathParams:
          id: roomId

      @action.roomRemove(roomId)
      expect(@api.rooms.remove.delete).toHaveBeenCalledWith config

  describe 'Method: roomRemoveMember', ->
    it 'should call api', ->
      spyOn(@api.rooms.removemember, 'post').and.callThrough()

      data =
        _roomId: 1
        _userId: 2
      config =
        pathParams:
          id: data._roomId
        data:
          _userId: data._userId

      @action.roomRemoveMember(data)
      expect(@api.rooms.removemember.post).toHaveBeenCalledWith config

  describe 'Method: roomArchive', ->
    it 'should call api', ->
      spyOn(@api.rooms.archive, 'post').and.callThrough()

      roomId = 1
      isArchived = true
      config =
        pathParams:
          id: roomId
        data:
          isArchived: isArchived

      @action.roomArchive(roomId, isArchived)
      expect(@api.rooms.archive.post).toHaveBeenCalledWith config

  describe 'Method: roomUpdate', ->
    it 'should call api', ->
      spyOn(@api.rooms.update, 'put').and.callThrough()

      roomId = 1
      data = {}
      config =
        pathParams:
          id: roomId
        data: data

      @action.roomUpdate(roomId, data)
      expect(@api.rooms.update.put).toHaveBeenCalledWith config

  describe 'Method: roomUpdateGuest', ->
    it 'should call api', ->
      spyOn(@api.rooms.guest, 'post').and.callThrough()

      roomId = 1
      enabled = true
      config =
        pathParams:
          id: roomId
        data:
          isGuestEnabled: enabled

      @action.roomUpdateGuest(roomId, enabled)
      expect(@api.rooms.guest.post).toHaveBeenCalledWith config
