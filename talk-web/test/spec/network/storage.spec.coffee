Immutable = require 'immutable'

describe 'storage', ->

  beforeunloadCB = null

  beforeEach ->
    spyOn window, 'addEventListener'
    @storage = require 'network/storage'
    @recorder = require 'actions-recorder'
    @schema = require 'schema'

    spyOn(@recorder, 'getState')

    beforeunloadCB = window.addEventListener.calls.mostRecent().args[1]

  afterEach ->
    localStorage.clear()

  describe 'window.addEventListener beforeunload', ->
    store = null

    beforeEach ->
      store = Immutable.fromJS
        drafts: {}
        # localStorage cleared after logout
        settings:
          isLoggedIn: true

      @recorder.getState.and.returnValue store

    it 'should add beforeunload', ->
      expect(window.addEventListener.calls.mostRecent().args[0]).toBe 'beforeunload'

    it 'should add store to localStorage', ->
      beforeunloadCB()
      jianliaoStore = JSON.stringify(store)
      expect(localStorage.getItem('jianliaoStoreV3')).toEqual jianliaoStore

    it 'should clear localStorage after logout', ->
      store = Immutable.fromJS
        drafts: {}
        settings: {}
        device:
          isLoggedIn: false
      @recorder.getState.and.returnValue store
      beforeunloadCB()
      expect(localStorage.getItem('jianliaoStoreV3')).toEqual null

  describe 'method: get', ->
    afterEach ->
      localStorage.clear()

    it 'should get empty Map if localStorage is empty', ->
      localStorage.clear()
      expect(@storage.get()).toEqualImmutable Immutable.Map()

    it 'should get data', ->
      localStorage.setItem 'jianliaoStoreV3', JSON.stringify({a: 1})
      expect(@storage.get()).toEqualImmutable Immutable.Map({a: 1})
