Immutable = require 'immutable'

describe 'Updater: unread', ->

  beforeEach ->
    @unread = require 'updater/unread'

  it 'should define methods', ->
    expect(@unread.check).toBeDefined()

  describe 'method: check', ->
    store = null
    checkData = null
    _teamId1 = _targetId1 = _targetId2 = unread1 = null

    getCheckData = (_teamId, _targetId, unread) ->
      _targetId1 = _targetId
      unread = unread
      unreadData = {}
      unreadData[_targetId1] = unread
      Immutable.fromJS
        _teamId: _teamId
        data: unreadData

    getStore = (_teamId, _targetId) ->
      notifications = {}
      notifications[_teamId] = [
        {_targetId: _targetId, unreadNum: 0, isMute: false}
        {_targetId: _targetId2, unreadNum: 0, isMute: true}
      ]
      Immutable.fromJS
        notifications: notifications

    beforeEach ->
      _teamId1 = '_teamId1'
      _targetId1 = '_targetId1'
      _targetId2 = '_targetId2'
      unread1 = 1
      checkData = getCheckData(_teamId1, _targetId1, unread1)
      store = getStore(_teamId1, _targetId1)

    it 'should update notifications', ->
      newStore = @unread.check(store, checkData)

      unreadNum = newStore
        .getIn ['notifications', _teamId1]
        .find (n) ->
          n.get('_targetId') is _targetId1
        .get('unreadNum')

      expect(unreadNum).toBe unread1

    it 'should update teams unread', ->
      newStore = @unread.check(store, checkData)
      teamUnread = newStore.getIn ['teams', _teamId1, 'unread']
      expect(teamUnread).toBe unread1

    it 'should not update team unread if notifications is muted', ->
      checkData = checkData.setIn ['data', _targetId2], 100
      newStore = @unread.check(store, checkData)
      teamUnread = newStore.getIn ['teams', _teamId1, 'unread']
      expect(teamUnread).toBe unread1

    it 'should clear unread if unread data is an empty object', ->
      store = store.updateIn ['notifications', _teamId1], (notifications) ->
        notifications.push Immutable.fromJS({_targetId: '_targetId3', unreadNum: 1, isMute: false})
      newStore = @unread.check(store, Immutable.fromJS({_teamId: _teamId1, data: {}}))
      teamUnread = newStore.getIn ['teams', _teamId1, 'unread']
      expect(teamUnread).toBe 0
