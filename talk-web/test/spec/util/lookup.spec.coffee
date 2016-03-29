Immutable = require 'immutable'

describe 'lookup: lookup', ->

  beforeEach ->
    @lookup = require 'util/lookup'

  describe 'function: getMessageChannelId', ->
    it 'should get _roomId', ->
      _roomId = '_roomId'
      data = Immutable.fromJS
        _roomId: _roomId
        _storyId: undefined
        _toId: undefined
        _creatorId: '_creatorId'
        _id: '_id'
      expect(@lookup.getMessageChannelId(data)).toBe _roomId

    it 'should get _storyId', ->
      _storyId = '_storyId'
      data = Immutable.fromJS
        _roomId: undefined
        _storyId: _storyId
        _toId: undefined
        _creatorId: '_creatorId'
        _id: '_id'
      expect(@lookup.getMessageChannelId(data)).toBe _storyId

    it 'should get _toId', ->
      _toId = '_toId'
      data = Immutable.fromJS
        _roomId: undefined
        _storyId: undefined
        _toId: _toId
        _creatorId: '_creatorId'
        _id: '_id'
      expect(@lookup.getMessageChannelId(data)).toBe _toId

    it 'should handle _userId check and return _creatorId when receiving messages', ->
      _toId = '_myId'
      _userId = '_myId' # message sent to me
      _creatorId = '_creatorId'
      data = Immutable.fromJS
        _roomId: undefined
        _storyId: undefined
        _toId: _toId
        _creatorId: _creatorId
        _id: '_id'
      expect(@lookup.getMessageChannelId(data, _userId)).toBe _creatorId
