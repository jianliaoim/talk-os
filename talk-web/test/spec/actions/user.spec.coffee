xdescribe 'Actions: user', ->

  beforeEach ->
    @action = require 'actions/user'
    @api = require 'network/api'

  describe 'Method: userSignout', ->
    it 'should call api', ->
      spyOn(@api.users.signout, 'post').and.callThrough()
      @action.userSignout()
      expect(@api.users.signout.post).toHaveBeenCalled()

  describe 'Method: userMe', ->
    it 'should call api', ->
      spyOn(@api.users.me, 'get').and.callThrough()
      @action.userMe()
      expect(@api.users.me.get).toHaveBeenCalled()

  describe 'Method: userUpdate', ->
    it 'should call api', ->
      spyOn(@api.users.update, 'put').and.callThrough()

      userId = 1
      data = {}
      config =
        pathParams:
          id: userId
        data: data

      @action.userUpdate(userId, data)
      expect(@api.users.update.put).toHaveBeenCalledWith config

  describe 'Method: state', ->
    it 'should call api', ->
      spyOn(@api.state, 'get').and.callThrough()

      teamId = 1
      config =
        queryParams:
          _teamId: teamId
          scope: 'version,checkfornewnotice,unread'

      @action.state(teamId)
      expect(@api.state.get).toHaveBeenCalledWith config

  describe 'Method: recommandFriends', ->
    it 'should call api', ->
      spyOn(@api.recommends.friends, 'get').and.callThrough()
      @action.recommandFriends()
      expect(@api.recommends.friends.get).toHaveBeenCalled()
