xdescribe 'Actions: contact-prefs', ->

  beforeEach ->
    @action = require 'actions/contact-prefs'
    @api = require 'network/api'

  describe 'Method: updateInTeam', ->
    it 'should call api', ->
      spyOn(@api.teams.prefs, 'put').and.callThrough()

      teamId = 1
      userId = 2
      data = {}
      config =
        pathParams:
          id: teamId
        data: data

      @action.updateInTeam(teamId, userId, data)
      expect(@api.teams.prefs.put).toHaveBeenCalledWith config
