xdescribe 'Actions: topic-prefs', ->

  beforeEach ->
    @action = require 'actions/topic-prefs'
    @api = require 'network/api'

  describe 'Method: update', ->
    it 'should call api', ->
      spyOn(@api.rooms.prefs, 'put').and.callThrough()

      roomId = 1
      data = {}
      config =
        pathParams:
          id: roomId
        data: data

      @action.update(roomId, data)
      expect(@api.rooms.prefs.put).toHaveBeenCalledWith config
