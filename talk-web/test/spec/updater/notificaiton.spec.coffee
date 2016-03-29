Immutable = require 'immutable'

describe 'Updater: notification', ->

  beforeEach ->
    @notification = require 'updater/notification'

  it 'should define methods', ->
    expect(@notification.update).toBeDefined()

  describe 'method: update', ->
    describe '["notifications", _teamId]', ->
      it 'should update notification by id', ->
        store = Immutable.fromJS
          device:
            _teamId: '_teamId1' # current team
          notifications:
            _teamId1: [
              {_id: '_id1', _teamId: '_teamId1', unreadNum: 0}
              {_id: '_id2', _teamId: '_teamId1', unreadNum: 999}
            ]
          teams:
            _teamId1: {}

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 555
        newStore1 = @notification.update(store, newNotification)

        expect(newStore1.get('notifications')).toEqualImmutable Immutable.fromJS
          _teamId1: [
            {_id: '_id1', _teamId: '_teamId1', unreadNum: 555}
            {_id: '_id2', _teamId: '_teamId1', unreadNum: 999}
          ]

        newNotification = Immutable.fromJS
          _id: '_id2', _teamId: '_teamId1', unreadNum: 0
        newStore2 = @notification.update(newStore1, newNotification)

        expect(newStore2.get('notifications')).toEqualImmutable Immutable.fromJS
          _teamId1: [
            {_id: '_id1', _teamId: '_teamId1', unreadNum: 555}
            {_id: '_id2', _teamId: '_teamId1', unreadNum: 0}
          ]

      it 'should add notificaiton if team has undefined notifications', ->
        store = Immutable.fromJS
          device:
            _teamId: '_teamId1' # current team
          notifications: {}
          teams:
            _teamId1: {}

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 555
        newStore = @notification.update(store, newNotification)

        expect(newStore.get('notifications')).toEqualImmutable Immutable.fromJS
          _teamId1: [
            {_id: '_id1', _teamId: '_teamId1', unreadNum: 555}
          ]

      it 'should add notificaiton if team has no notifications', ->
        store = Immutable.fromJS
          device:
            _teamId: '_teamId1' # current team
          notifications:
            _teamId1: []
          teams:
            _teamId1: {}

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 555
        newStore = @notification.update(store, newNotification)

        expect(newStore.get('notifications')).toEqualImmutable Immutable.fromJS
          _teamId1: [
            {_id: '_id1', _teamId: '_teamId1', unreadNum: 555}
          ]

      it 'should append notificaiton if team has does not have this notifications', ->
        store = Immutable.fromJS
          device:
            _teamId: '_teamId1' # current team
          notifications:
            _teamId1: [
              {_id: '_id2', _teamId: '_teamId1', unreadNum: 0}
            ]
          teams:
            _teamId1: {}

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 555
        newStore = @notification.update(store, newNotification)

        expect(newStore.get('notifications')).toEqualImmutable Immutable.fromJS
          _teamId1: [
            {_id: '_id1', _teamId: '_teamId1', unreadNum: 555}
            {_id: '_id2', _teamId: '_teamId1', unreadNum: 0}
          ]

      it 'should update notificaiton if another team has this notification', ->
        store = Immutable.fromJS
          device:
            _teamId: '_teamId1' # current team
          notifications:
            _teamId1: []
            _teamId2: [
              _id: '_id1', _teamId: '_teamId2', unreadNum: 0
            ]
          teams:
            _teamId1: {}

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId2', unreadNum: 555
        newStore = @notification.update(store, newNotification)

        expect(newStore.get('notifications')).toEqualImmutable Immutable.fromJS
          _teamId1: []
          _teamId2: [
            {_id: '_id1', _teamId: '_teamId2', unreadNum: 555}
          ]

      it 'should NOT update notificaiton if another team does not have this notification, so data-rely can retrive the whole notifications list after changing the team', ->
        store = Immutable.fromJS
          device:
            _teamId: '_teamId1' # current team
          notifications:
            _teamId1: []
          teams:
            _teamId1: {}


        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId2', unreadNum: 555
        newStore = @notification.update(store, newNotification)

        expect(newStore.get('notifications')).toEqualImmutable Immutable.fromJS
          _teamId1: []

    describe '["teams", _teamId, "unread"]', ->
      it 'should update the unread number of the team', ->
        store = Immutable.fromJS
          teams:
            _teamId1:
              unread: 0

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 555, oldUnreadNum: 0
        newStore1 = @notification.update(store, newNotification)

        expect(newStore1.getIn(['teams', '_teamId1', 'unread'])).toBe 555

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 0, oldUnreadNum: 555
        newStore2 = @notification.update(newStore1, newNotification)

        expect(newStore2.getIn(['teams', '_teamId1', 'unread'])).toBe 0

      it 'should not have negative unreads (maybe the bad data is bad)', ->
        store = Immutable.fromJS
          teams:
            _teamId1:
              unread: 200

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 500, oldUnreadNum: 1000
        newStore = @notification.update(store, newNotification)

        expect(newStore.getIn(['teams', '_teamId1', 'unread'])).toBe 0

      it 'should not process undefined team unread', ->
        store = Immutable.fromJS
          teams: {}

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 1, oldUnreadNum: 0
        newStore = @notification.update(store, newNotification)

        expect(newStore.getIn(['teams', '_teamId1', 'unread'])).toBe undefined

      it 'should process undefined oldUnreadNum for team unread (clearing local notification)', ->
        store = Immutable.fromJS
          teams:
            _teamId1:
              unread: 3

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 1
        newStore = @notification.update(store, newNotification)

        expect(newStore.getIn(['teams', '_teamId1', 'unread'])).toBe 2

      it 'should not update the unread number if the notification is muted', ->
        store = Immutable.fromJS
          teams:
            _teamId1:
              unread: 0

        newNotification = Immutable.fromJS
          _id: '_id1', _teamId: '_teamId1', unreadNum: 1, oldUnreadNum: 0, isMute: true
        newStore = @notification.update(store, newNotification)

        expect(newStore.getIn(['teams', '_teamId1', 'unread'])).toBe 0

      it 'should sync unread of current team with its notifications', ->
        store = Immutable.fromJS
          device:
            _teamId: '_teamId1'
          teams:
            _teamId1:
              unread: 5
          notifications:
            _teamId1: [
              {_id: '_id1', _teamId: '_teamId1', unreadNum: 1, oldUnreadNum: 0, isMute: false}
              {_id: '_id2', _teamId: '_teamId1', unreadNum: 2, oldUnreadNum: 0, isMute: false}
              {_id: '_id3', _teamId: '_teamId1', unreadNum: 3, oldUnreadNum: 0, isMute: true}
            ]

        newNotification = Immutable.fromJS
          _id: '_id4', _teamId: '_teamId1', unreadNum: 4, oldUnreadNum: 0, isMute: false
        newStore = @notification.update(store, newNotification)

        expect(newStore.getIn(['teams', '_teamId1', 'unread'])).toBe 7
