xdescribe 'Actions: prefs', ->

  beforeEach ->
    @action = require 'actions/prefs'
    @api = require 'network/api'

  describe 'Method: prefsUpdate', ->
    it 'should call api', ->
      spyOn(@api.preferences.update, 'put').and.callThrough()

      data = {}
      config = data: data

      @action.prefsUpdate(data)
      expect(@api.preferences.update.put).toHaveBeenCalledWith config
