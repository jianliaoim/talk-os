describe 'util: loading-sentences', ->

  beforeEach ->
    @util = require 'util/loading-sentences'

  describe 'function: get', ->
    it 'should return a sentence for any other date', ->
      date = new Date(2016, 1, 12)
      sentences = @util.list
      expect(sentences).toContain @util.get(date)
