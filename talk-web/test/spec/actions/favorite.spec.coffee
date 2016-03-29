xdescribe 'Actions: favorite', ->

  beforeEach ->
    @action = require 'actions/favorite'
    @api = require 'network/api'

  describe 'Method: createFavorite', ->
    it 'should call api', ->
      spyOn(@api.favorites.create, 'post').and.callThrough()

      message = id: 1
      config =
        data:
          _messageId: message.id

      @action.createFavorite(message)
      expect(@api.favorites.create.post).toHaveBeenCalledWith config

  describe 'Method: readFavorite', ->
    it 'should call api', ->
      spyOn(@api.favorites.read, 'get').and.callThrough()

      teamId = 1
      config =
        queryParams:
          _teamId: teamId

      @action.readFavorite(teamId)
      expect(@api.favorites.read.get).toHaveBeenCalledWith config

  describe 'Method: removeFavorite', ->
    it 'should call api', ->
      spyOn(@api.favorites.remove, 'delete').and.callThrough()

      messageId = 1
      config =
        pathParams:
          id: messageId

      @action.removeFavorite(messageId)
      expect(@api.favorites.remove.delete).toHaveBeenCalledWith config

  describe 'Method: searchFavorite', ->
    it 'should call api', ->
      spyOn(@api.favorites.search, 'post').and.callThrough()

      data = {}
      config =
        data: data

      @action.searchFavorite(data)
      expect(@api.favorites.search.post).toHaveBeenCalledWith config
