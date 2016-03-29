Immutable = require 'immutable'

defaultStore = Immutable.fromJS
  settings:
    showFavorites: false
    showInteBanner: true
    showCollection: false
    showTag: false
    teamFootprints: {} # _teamId => unix time
    foldedContacts: {} # [_teamId, _contactId]

describe 'Updater: settings', ->

  beforeEach ->
    @updater = require 'updater/settings'

  it 'should define methods', ->
    expect(@updater.update).toBeDefined()
    expect(@updater.teamFootprints).toBeDefined()
    expect(@updater.foldContact).toBeDefined()
    expect(@updater.unfoldContact).toBeDefined()

  describe 'method: update', ->
    store = null
    actionData = null

    beforeEach ->
      store = defaultStore

      actionData = Immutable.fromJS
        showFavorites: true
        showInteBanner: false
        showCollection: true
        showTag: true

    it 'should update settings', ->
      newStore = @updater.update(store, actionData)
      expected = Immutable.fromJS
        showFavorites: true
        showInteBanner: false
        showCollection: true
        showTag: true
        teamFootprints: {} # _teamId => unix time
        foldedContacts: {} # [_teamId, _contactId]

      expect(newStore.getIn(['settings'])).toEqualImmutable(expected)

  describe 'method: teamFootprints', ->
    store = null
    actionData = null

    beforeEach ->
      store = defaultStore

      actionData = Immutable.fromJS
        _teamId: '1'
        time: '2'

    it 'should update teamFootprints', ->
      newStore = @updater.teamFootprints(store, actionData)
      expected = '2'

      expect(newStore.getIn(['settings', 'teamFootprints', '1'])).toEqual('2')

  describe 'method: foldContact', ->
    store = null
    actionData = null

    beforeEach ->
      store = defaultStore

      actionData = Immutable.fromJS
        _teamId: '1'
        _id: '2'

    it 'should update teamFootprints', ->
      newStore = @updater.foldContact(store, actionData)
      _teamId = actionData.get('_teamId')
      _id = actionData.get('_id')

      expect(newStore.getIn(['settings', 'foldedContacts', _teamId, _id])).toEqual(true)

  describe 'method: unfoldContact', ->
    store = null
    actionData = null

    beforeEach ->
      store = defaultStore

      actionData = Immutable.fromJS
        _teamId: '1'
        _id: '2'

    it 'should update teamFootprints', ->
      newStore = @updater.unfoldContact(store, actionData)
      _teamId = actionData.get('_teamId')
      _id = actionData.get('_id')

      expect(newStore.getIn(['settings', 'foldedContacts', _teamId, _id])).toEqual(false)
