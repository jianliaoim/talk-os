describe 'util: loading-sentences', ->

  beforeEach ->
    @util = require 'util/loading-sentences'

  describe 'function: get', ->
    it 'should return a sentence for 愚人节 (2016/04/1)', ->
      date = new Date(2016, 3, 1)
      sentences = @util.list['2016/4/1']
      expect(sentences).toContain @util.get(date)

    it 'should return a sentence for any other date', ->
      date = new Date(2016, 1, 12)
      sentences = @util.list['others']
      expect(sentences).toContain @util.get(date)
