Immutable = require 'immutable'

describe 'Updater: mentioned message', ->

  beforeEach ->
    @updater = require 'updater/mentioned-message'

  describe 'Method: clear', ->

    it 'should clear all mentioned messages data relative to team', ->
      prevStore = Immutable.fromJS
        mentionedMessages:
          team: [1, 2, 3, 4, 5]

      expectStore = Immutable.fromJS
        mentionedMessages:
          team: []

      incomingData = Immutable.fromJS
        params:
          _teamId: 'team'

      store = @updater.clear prevStore, incomingData
      expect(store).toEqualImmutable expectStore

  describe 'Method: read', ->

    emptyStore = Immutable.fromJS
      mentionedMessages: {}

    describe '[mentionedMessages, _teamId]', ->

      it 'should create empty Immutable.List() if it doesn\'t exist team reference key', ->
        incomingData = Immutable.fromJS
          params:
            _teamId: '_teamId1'

        store = @updater.read emptyStore, incomingData

        expectStore = emptyStore.setIn ['mentionedMessages', '_teamId1'], Immutable.List()

        expect(store).toEqualImmutable expectStore

      it 'should insert messages once received', ->
        incomingData = Immutable.fromJS
          data: [1, 2, 3]
          params:
            _teamId: '_teamId2'

        store = @updater.read emptyStore, incomingData

        expectData = Immutable.List [1, 2, 3]
        expectStore = emptyStore.setIn ['mentionedMessages', '_teamId2'], expectData

        expect(store).toEqualImmutable expectStore

      it 'should sort messages after received', ->
        unsortedMessages = Immutable.fromJS [
          { createdAt: new Date(2016, 1, 2) }
          { createdAt: new Date(2016, 1, 1) }
          { createdAt: new Date(2016, 1, 4) }
          { createdAt: new Date(2016, 1, 3) }
        ]

        incomingData = Immutable.fromJS
          data: unsortedMessages
          params:
            _teamId: '_teamId3'

        store = @updater.read emptyStore, incomingData

        expectMessages = Immutable.fromJS [
          { createdAt: new Date(2016, 1, 4) }
          { createdAt: new Date(2016, 1, 3) }
          { createdAt: new Date(2016, 1, 2) }
          { createdAt: new Date(2016, 1, 1) }
        ]
        expectStore = emptyStore.setIn ['mentionedMessages', '_teamId3'], expectMessages

        expect(store).toEqualImmutable expectStore

      it 'should concat messages and sort it after received new messages', ->
        prevMessages = Immutable.fromJS [
          { createdAt: new Date(2016, 1, 4) }
          { createdAt: new Date(2016, 1, 3) }
          { createdAt: new Date(2016, 1, 2) }
          { createdAt: new Date(2016, 1, 1) }
        ]
        prevStore = emptyStore.setIn ['mentionedMessages', '_teamId4'], prevMessages

        newMessages = Immutable.fromJS [
          { createdAt: new Date(2016, 1, 5) }
          { createdAt: new Date(2016, 1, 6) }
          { createdAt: new Date(2016, 1, 7) }
        ]
        incomingData = Immutable.fromJS
          data: newMessages
          params:
            _teamId: '_teamId4'

        store = @updater.read prevStore, incomingData

        expectMessages = Immutable.fromJS [
          { createdAt: new Date(2016, 1, 7) }
          { createdAt: new Date(2016, 1, 6) }
          { createdAt: new Date(2016, 1, 5) }
          { createdAt: new Date(2016, 1, 4) }
          { createdAt: new Date(2016, 1, 3) }
          { createdAt: new Date(2016, 1, 2) }
          { createdAt: new Date(2016, 1, 1) }
        ]
        expectStore = emptyStore.setIn ['mentionedMessages', '_teamId4'], expectMessages

        expect(store).toEqualImmutable expectStore
