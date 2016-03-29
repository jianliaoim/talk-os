Immutable = require 'immutable'

xdescribe 'Controllers: file', ->

  beforeEach ->
    @controller = require 'updater/file'

  it 'should define methods', ->
    expect(@controller.create).toBeDefined()
    expect(@controller.progress).toBeDefined()
    expect(@controller.complete).toBeDefined()
    expect(@controller.error).toBeDefined()

  describe 'method: create', ->
    _teamId = _toId = store = actionData = updatePath = addFileState = null

    beforeEach ->
      _teamId = '_teamId'
      _toId = '_toId'
      store = {}
      store.messages = {}
      store.messages[_teamId] = {}
      store.messages[_teamId][_toId] = []
      store = Immutable.fromJS(store)
      actionData = Immutable.fromJS {
        _teamId: _teamId
        _toId: _toId
        body: '1'
      }
      updatePath = ['messages', _teamId, _toId]

      addFileState = (actionData) ->
        actionData
          .setIn(['attachments', 0, 'isUploading'], true)
          .setIn(['attachments', 0, 'progress'], 0)

    it 'should push a new message', ->
      store1 = @controller.create(store, actionData)
      expect(store1.getIn(updatePath)).toEqualImmutable Immutable.fromJS([addFileState(actionData)])

      actionData2 = Immutable.fromJS {
        _teamId: _teamId
        _toId: _toId
        body: '2'
      }
      store2 = @controller.create(store1, actionData2)
      expect(store2.getIn(updatePath)).toEqualImmutable Immutable.fromJS([addFileState(actionData), addFileState(actionData2)])

    it 'should add isUploading and progress status', ->
      newStore = @controller.create(store, actionData)
      newMessage = addFileState(actionData)
      expect(newStore.getIn(updatePath)).toEqualImmutable Immutable.fromJS([newMessage])

  describe 'method: progress', ->
    store = actionData = updatePath = progress = null

    beforeEach ->
      _teamId = '_teamId'
      _toId = '_toId'
      fileId = 'fileId'
      progress = 0.5
      store = {}
      store.messages = {}
      store.messages[_teamId] = {}
      store.messages[_teamId][_toId] = [{
        _teamId: _teamId
        _toId: _toId
        body: '1'
        attachments: [{
          data:
            fileId: fileId
          progress: 0
        }]
      }]
      store = Immutable.fromJS(store)
      actionData = Immutable.fromJS {
        fileData:
          fileId: fileId
        userData:
          _teamId: _teamId
          _toId: _toId
        progress: progress
      }
      updatePath = ['messages', _teamId, _toId]

    it 'should update file progress', ->
      newStore = @controller.progress(store, actionData)
      expect(newStore.getIn(updatePath).getIn([0, 'attachments', 0, 'progress'])).toEqual 0.5

  describe 'method: complete', ->
    store = actionData = updatePath = null

    beforeEach ->
      _teamId = '_teamId'
      _toId = '_toId'
      fileId = 'fileId'
      store = {}
      store.messages = {}
      store.messages[_teamId] = {}
      store.messages[_teamId][_toId] = [{
        _teamId: _teamId
        _toId: _toId
        body: '1'
        attachments: [{
          data:
            fileId: fileId
          progress: 0.5
        }]
      }]
      store = Immutable.fromJS(store)
      actionData = Immutable.fromJS {
        fileData:
          fileId: fileId
        userData:
          _teamId: _teamId
          _toId: _toId
      }
      updatePath = ['messages', _teamId, _toId]

    it 'should update progress and isUploading status', ->
      newStore = @controller.complete(store, actionData)
      expect(newStore.getIn(updatePath).getIn([0, 'attachments', 0, 'progress'])).toEqual 1
      expect(newStore.getIn(updatePath).getIn([0, 'attachments', 0, 'isUploading'])).toEqual false

  describe 'method: error', ->
    store = actionData = updatePath = null

    beforeEach ->
      _teamId = '_teamId'
      _toId = '_toId'
      fileId = 'fileId'
      store = {}
      store.messages = {}
      store.messages[_teamId] = {}
      store.messages[_teamId][_toId] = [{
        _teamId: _teamId
        _toId: _toId
        body: '1'
        attachments: [{
          data:
            fileId: fileId
          progress: 0
        }]
      }]
      store = Immutable.fromJS(store)
      actionData = Immutable.fromJS {
        fileData:
          fileId: fileId
        userData:
          _teamId: _teamId
          _toId: _toId
      }
      updatePath = ['messages', _teamId, _toId]

    it 'should remove the file message', ->
      newStore = @controller.error(store, actionData)
      expect(newStore.getIn(updatePath).size).toBe 0
