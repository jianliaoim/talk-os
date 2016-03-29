xdescribe 'Actions: message', ->

  beforeEach ->
    @action = require 'actions/message'
    @api = require 'network/api'

  describe 'Method: messageMore', ->
    it 'should call api', ->
      spyOn(@api.messages.read, 'get').and.callThrough()

      data = query: 'query'
      config = queryParams: data

      @action.messageMore(data)
      expect(@api.messages.read.get).toHaveBeenCalledWith config

  describe 'Method: requestMore', ->
    it 'should call api', ->
      spyOn(@api.messages.read, 'get').and.callThrough()

      data = query: 'query'
      config = queryParams: data

      @action.requestMore(data)
      expect(@api.messages.read.get).toHaveBeenCalledWith config

  describe 'Method: messageCreate', ->
    it 'should call api', ->
      userStore = require 'store/user'
      spyOn(userStore, 'get').and.returnValue 'creator'
      spyOn(@api.messages.create, 'post').and.callThrough()

      data =
        creator: 'creator'
      config = data: data

      @action.messageCreate(data)
      expect(@api.messages.create.post).toHaveBeenCalledWith config

  describe 'Method: messageUpdate', ->
    it 'should call api', ->
      spyOn(@api.messages.update, 'put').and.callThrough()

      messageId = 1
      data = {}
      config =
        pathParams:
          id: messageId
        data: data

      @action.messageUpdate(messageId, data)
      expect(@api.messages.update.put).toHaveBeenCalledWith config

  describe 'Method: messageDelete', ->
    it 'should call api', ->
      spyOn(@api.messages.remove, 'delete').and.callThrough()

      message = _id: 1
      config =
        pathParams:
          id: message._id

      @action.messageDelete(message)
      expect(@api.messages.remove.delete).toHaveBeenCalledWith config

  describe 'Method: messageReadChat', ->
    it 'should call api', ->
      spyOn(@api.messages.read, 'get').and.callThrough()

      teamId = 1
      userId = 2
      config =
        queryParams:
          _teamId: teamId
          _toId: userId

      @action.messageReadChat(teamId, userId)
      expect(@api.messages.read.get).toHaveBeenCalledWith config

  describe 'Method: starMessage', ->
    it 'should call api', ->
      spyOn(@api.messages.star, 'post').and.callThrough()

      messageId = 1
      config =
        pathParams:
          id: messageId

      @action.starMessage(messageId)
      expect(@api.messages.star.post).toHaveBeenCalledWith config

  describe 'Method: unstarMessage', ->
    it 'should call api', ->
      spyOn(@api.messages.unstar, 'post').and.callThrough()

      messageId = 1
      config =
        pathParams:
          id: messageId

      @action.unstarMessage(messageId)
      expect(@api.messages.unstar.post).toHaveBeenCalledWith config

  describe 'Method: uploadFile', ->
    it 'should call api', ->
      spyOn(@api.messages.create, 'post').and.callThrough()

      data = {}
      config = data: data

      @action.uploadFile(data)
      expect(@api.messages.create.post).toHaveBeenCalledWith config
