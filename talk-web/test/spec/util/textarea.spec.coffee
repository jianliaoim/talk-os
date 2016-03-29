describe 'util: textarea', ->

  beforeEach ->
    @textarea = require 'util/textarea'

  describe 'function: getTrigger', ->
    specials = ['@', '#']

    it 'should handle normal text', ->
      expect(@textarea.getTrigger('test', specials)).toBeNull()

    it 'should handle text with specials', ->
      expect(@textarea.getTrigger('@test', specials)).toBe '@'
      expect(@textarea.getTrigger('#test', specials)).toBe '#'

    it 'should handle whitespaces', ->
      expect(@textarea.getTrigger('@test asdf', specials)).toBeNull()
      expect(@textarea.getTrigger('#test asdf', specials)).toBeNull()

  describe 'function: getQuery', ->
    it 'should get the query', ->
      expect(@textarea.getQuery('@test', '@')).toBe 'test'
      expect(@textarea.getQuery('#test', '#')).toBe 'test'
      expect(@textarea.getQuery('@test test', '@')).toBe 'test test'

    it 'should handle text in front of the special', ->
      expect(@textarea.getQuery(' @test2   \n @test', '@')).toBe 'test'

    it 'should empty queries', ->
      expect(@textarea.getQuery(':', ':')).toBe ''

  describe 'function: makeCompleteState', ->
    it 'should find the trigger and replace the text', ->
      wholeText = "test @retest"
      state = @textarea.makeCompleteState(wholeText, 8, '@', '@REPLACE ')
      expect(state).toEqual
        text: "test @REPLACE test"
        start: "test @REPLACE ".length
        end: "test @REPLACE ".length
