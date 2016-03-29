xdescribe 'Actions: inte', ->

  beforeEach ->
    @action = require 'actions/inte'
    @api = require 'network/api'

  describe 'Method: inteFetch', ->
    it 'should call api', ->
      spyOn(@api.integrations.read, 'get').and.callThrough()

      teamId = 1
      config =
        queryParams:
          _teamId: teamId

      @action.inteFetch(teamId)
      expect(@api.integrations.read.get).toHaveBeenCalledWith config

  describe 'Method: inteUpdate', ->
    it 'should call api', ->
      spyOn(@api.integrations.update, 'put').and.callThrough()

      inteId = 1
      data = {}
      config =
        pathParams:
          id: inteId
        data: data

      @action.inteUpdate(inteId, data)
      expect(@api.integrations.update.put).toHaveBeenCalledWith config

  describe 'Method: inteCreate', ->
    it 'should call api', ->
      spyOn(@api.integrations.create, 'post').and.callThrough()

      data = {}
      config = data: data

      @action.inteCreate(data)
      expect(@api.integrations.create.post).toHaveBeenCalledWith config

  describe 'Method: inteRemove', ->
    it 'should call api', ->
      spyOn(@api.integrations.remove, 'delete').and.callThrough()

      inte = _id: 1
      config =
        pathParams:
          id: inte._id

      @action.inteRemove(inte)
      expect(@api.integrations.remove.delete).toHaveBeenCalledWith config

  describe 'Method: checkRss', ->
    it 'should call api', ->
      spyOn(@api.integrations.checkrss, 'get').and.callThrough()

      url = 'http://example.com'
      config =
        queryParams:
          url: url

      @action.checkRss(url)
      expect(@api.integrations.checkrss.get).toHaveBeenCalledWith config

  describe 'Method: getSettings', ->
    it 'should call api', ->
      spyOn(@api.services.settings, 'get').and.callThrough()
      @action.getSettings()
      expect(@api.services.settings.get).toHaveBeenCalled()
