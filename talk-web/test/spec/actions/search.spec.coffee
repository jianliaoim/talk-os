xdescribe 'Actions: search', ->

  beforeEach ->
    @action = require 'actions/search'
    @api = require 'network/api'

  describe 'Method: query', ->
    it 'should call api', ->
      spyOn(@api.messages.search, 'get').and.callThrough()

      teamId = 1
      q = 'query string'
      page = 2
      config =
        queryParams:
          _teamId: teamId
          q: q
          page: page

      @action.query(teamId, q, page)
      expect(@api.messages.search.get).toHaveBeenCalledWith config

  describe 'Method: collection', ->
    it 'should call api', ->
      spyOn(@api.messages.search, 'post').and.callThrough()

      data = {}
      config = data: data

      @action.collection(data)
      expect(@api.messages.search.post).toHaveBeenCalledWith config

  describe 'Method: collectionFile', ->
    it 'should call api', ->
      spyOn(@api.messages.search, 'post').and.callThrough()

      data = {}
      config = data: data

      @action.collectionFile(data)
      expect(data.type).toBe 'file'
      expect(@api.messages.search.post).toHaveBeenCalledWith config

  describe 'Method: collectionPost', ->
    it 'should call api', ->
      spyOn(@api.messages.search, 'post').and.callThrough()

      data = {}
      config = data: data

      @action.collectionPost(data)
      expect(data.type).toBe 'rtf'
      expect(@api.messages.search.post).toHaveBeenCalledWith config

  describe 'Method: collectionLink', ->
    it 'should call api', ->
      spyOn(@api.messages.search, 'post').and.callThrough()

      data = {}
      config = data: data

      @action.collectionLink(data)
      expect(data.type).toBe 'url'
      expect(@api.messages.search.post).toHaveBeenCalledWith config
