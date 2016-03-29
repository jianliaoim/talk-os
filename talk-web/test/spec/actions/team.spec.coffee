xdescribe 'Actions: team', ->

  beforeEach ->
    @action = require 'actions/team'
    @api = require 'network/api'

  describe 'Method: teamSubscribe', ->
    it 'should call api', ->
      spyOn(@api.teams.subscribe, 'post').and.callThrough()

      teamId = 1
      config =
        pathParams:
          id: teamId

      @action.teamSubscribe(teamId)
      expect(@api.teams.subscribe.post).toHaveBeenCalledWith config

  describe 'Method: teamUnsubscribe', ->
    it 'should call api', ->
      spyOn(@api.teams.unsubscribe, 'post').and.callThrough()

      teamId = 1
      config =
        pathParams:
          id: teamId

      @action.teamUnsubscribe(teamId)
      expect(@api.teams.unsubscribe.post).toHaveBeenCalledWith config

  describe 'Method: teamInvite', ->
    it 'should call api', ->
      spyOn(@api.teams.invite, 'post').and.callThrough()

      teamId = 1
      email = 'test@example.com'
      config =
        pathParams:
          id: teamId
        data:
          email: email

      @action.teamInvite(teamId, email)
      expect(@api.teams.invite.post).toHaveBeenCalledWith config

  describe 'Method: batchInvite', ->
    it 'should call api', ->
      spyOn(@api.teams.batchinvite, 'post').and.callThrough()

      teamId = 1
      emailArray = ['test1@example.com', 'test2@example.com']
      config =
        pathParams:
          id: teamId
        data:
          emails: emailArray

      @action.batchInvite(teamId, emailArray)
      expect(@api.teams.batchinvite.post).toHaveBeenCalledWith config

  describe 'Method: teamUpdate', ->
    it 'should call api', ->
      spyOn(@api.teams.update, 'put').and.callThrough()

      teamId = 1
      data = {}
      config =
        pathParams:
          id: teamId
        data: data

      @action.teamUpdate(teamId, data)
      expect(@api.teams.update.put).toHaveBeenCalledWith config

  describe 'Method: teamLeave', ->
    it 'should call api', ->
      spyOn(@api.teams.leave, 'post').and.callThrough()

      teamId = 1
      config =
        pathParams:
          id: teamId

      @action.teamLeave(teamId)
      expect(@api.teams.leave.post).toHaveBeenCalledWith config

  describe 'Method: teamCreate', ->
    it 'should call api', ->
      spyOn(@api.teams.create, 'post').and.callThrough()

      name = 'name'
      config = data: name: name

      @action.teamCreate(name)
      expect(@api.teams.create.post).toHaveBeenCalledWith config

  describe 'Method: teamsFetch', ->
    it 'should call api', ->
      spyOn(@api.teams.read, 'get').and.callThrough()
      @action.teamsFetch()
      expect(@api.teams.read.get).toHaveBeenCalled()

  describe 'Method: teamUnpin', ->
    it 'should call api', ->
      spyOn(@api.teams.unpin, 'post').and.callThrough()

      teamId = 1
      targetId = 2
      config =
        pathParams:
          id: teamId
          targetId: targetId

      @action.teamUnpin(teamId, targetId)
      expect(@api.teams.unpin.post).toHaveBeenCalledWith config

  describe 'Method: teamPin', ->
    it 'should call api', ->
      spyOn(@api.teams.pin, 'post').and.callThrough()

      teamId = 1
      targetId = 2
      config =
        pathParams:
          id: teamId
          targetId: targetId

      @action.teamPin(teamId, targetId)
      expect(@api.teams.pin.post).toHaveBeenCalledWith config

  describe 'Method: getArchivedTopics', ->
    it 'should call api', ->
      spyOn(@api.teams.rooms, 'get').and.callThrough()

      teamId = 1
      config =
        pathParams:
          id: teamId
        queryParams:
          isArchived: true

      @action.getArchivedTopics(teamId)
      expect(@api.teams.rooms.get).toHaveBeenCalledWith config

  describe 'Method: resetInviteUrl', ->
    it 'should call api', ->
      spyOn(@api.teams.refresh, 'post').and.callThrough()

      teamId = 1
      config =
        pathParams:
          id: teamId
        data:
          properties:
            inviteCode: 1

      @action.resetInviteUrl(teamId)
      expect(@api.teams.refresh.post).toHaveBeenCalledWith config
