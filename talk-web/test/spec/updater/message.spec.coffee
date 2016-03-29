Immutable = require 'immutable'

describe 'Updater: message', ->

  beforeEach ->
    @updater = require 'updater/message'

  describe 'function: receiptLoading', ->
    it 'should add receiptors in the given message', ->
      store = Immutable.fromJS
        user:
          _id: 'userId1'
        messages:
          teamId1:
            roomId1: [
              {_id: 'messageId1'}
            ]

      messageData = Immutable.fromJS
        _teamId: 'teamId1'
        _id: 'messageId1'
        _roomId: 'roomId1'
        _creatorId: 'userId2'

      newStore = @updater.receiptLoading(store, messageData)
      receiptors = newStore.getIn(['messages', 'teamId1', 'roomId1', 0, 'receiptors'])
      expect(receiptors).toEqualImmutable Immutable.fromJS(['userId1'])

    it 'should append to receiptors in the given message', ->
      store = Immutable.fromJS
        user:
          _id: 'userId1'
        messages:
          teamId1:
            roomId1: [
              {_id: 'messageId1', receiptors: ['userId3']}
            ]

      messageData = Immutable.fromJS
        _teamId: 'teamId1'
        _id: 'messageId1'
        _roomId: 'roomId1'
        _creatorId: 'userId2'

      newStore = @updater.receiptLoading(store, messageData)
      receiptors = newStore.getIn(['messages', 'teamId1', 'roomId1', 0, 'receiptors'])
      expect(receiptors).toEqualImmutable Immutable.fromJS(['userId3', 'userId1'])
