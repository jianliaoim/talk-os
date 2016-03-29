xdescribe 'Actions: search-message', ->

  beforeEach ->
    @action = require 'actions/search-message'
    @api = require 'network/api'

  describe 'Method: search', ->
    it 'should call api', ->
      spyOn(@api.messages.read, 'get').and.callThrough()

      data = {}
      config = queryParams: data

      @action.search(data)
      expect(@api.messages.read.get).toHaveBeenCalledWith config

  describe 'Method: before', ->
    it 'should call api', ->
      spyOn(@api.messages.read, 'get').and.callThrough()

      data = {}
      config = queryParams: data

      @action.before(data)
      expect(@api.messages.read.get).toHaveBeenCalledWith config

  describe 'Method: after', ->
    it 'should call api', ->
      spyOn(@api.messages.read, 'get').and.callThrough()

      data = {}
      config = queryParams: data

      @action.after(data)
      expect(@api.messages.read.get).toHaveBeenCalledWith config
