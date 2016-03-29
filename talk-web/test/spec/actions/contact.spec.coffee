xdescribe 'Actions: contact', ->

  beforeEach ->
    @action = require 'actions/contact'
    @api = require 'network/api'

  describe 'Method: contactRemove', ->
    it 'should call api', ->
      spyOn(@api.teams.removemember, 'post').and.callThrough()

      teamId = 1
      user   = _id: 2
      config =
        pathParams:
          id: teamId
        data:
          _userId: user._id

      @action.contactRemove(teamId, user)
      expect(@api.teams.removemember.post).toHaveBeenCalledWith config

  describe 'Method: contactUpdateRole', ->
    it 'should call api', ->
      spyOn(@api.teams.setmemberrole, 'post').and.callThrough()

      teamId = 1
      userId = 2
      role = 'admin'
      config =
        pathParams:
          id: teamId
        data:
          _userId: userId
          role: role

      @action.contactUpdateRole(teamId, userId, role)
      expect(@api.teams.setmemberrole.post).toHaveBeenCalledWith config
