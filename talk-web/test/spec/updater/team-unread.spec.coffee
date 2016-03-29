Immutable = require 'immutable'

describe 'Updater: unread and state', ->
  store = _teamId = null

  beforeEach ->
    @unread = require 'updater/unread'
    @notification = require 'updater/notification'

    _teamId = '_teamId1'

    store = Immutable.fromJS
      device:
        _teamId: '_teamId1'
      teams:
        _teamId1:
          unread: 10
      notifications:
        _teamId1: [
          {_id: '_id1', _targetId: '_targetId1', unreadNum: 2}
          {_id: '_id2', _targetId: '_targetId2', unreadNum: 8}
        ]

  it 'should match unread num', ->
    noty = store.getIn ['notifications', _teamId, 0]
    resp = Immutable.fromJS
      _id: '_id1'
      _teamId: _teamId
      unreadNum: 0
      oldUnreadNum: 2
    stateUnreadData = Immutable.fromJS
      _teamId: _teamId
      data:
        _targetId1: 2
        _targetId2: 8

    store = @notification.preClearTeamUnread(store, noty)
    # notifications.update noty 发送请求
    # /state unread 发送
    store = @unread.check(store, stateUnreadData)
    # notifications.update 请求返回 resp
    store = @notification.postClearTeamUnread(store, resp)
    store = @notification.update(store, resp)

    expect(store.getIn(['notifications', _teamId, 0, 'unreadNum'])).toBe 0
    expect(store.getIn(['notifications', _teamId, 1, 'unreadNum'])).toBe 8
    expect(store.getIn(['teams', _teamId, 'unread'])).toBe 8


