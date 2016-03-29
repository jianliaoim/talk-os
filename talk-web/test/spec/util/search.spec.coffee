Immutable = require 'immutable'

describe 'util: search', ->

  beforeEach ->
    @search = require 'util/search'

  describe 'function: indexOfPinyins', ->
    it 'should return the first position if there is a match', ->
      pinyins = Immutable.List(['xiaoai', 'xiaoyi'])

      query = 'x'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 0

      query = 'xiaoa'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 0

      query = 'xiaoy'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 0

      query = 'ai'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 4

      query = 'yi'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 4

      query = ''
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 0

    it 'should return the first position if there are mutiple matches', ->
      pinyins = Immutable.List(['xiaoai', 'xiaoyi', 'aaoao'])
      query = 'ao'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 1

    it 'should return -1 there are no matches', ->
      pinyins = Immutable.List(['xiaoai', 'xiaoyi'])
      query = 'zz'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual -1

    it 'should return -1 there are no pinyins', ->
      pinyins = Immutable.List([])
      query = 'zz'
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual -1

    it 'should make "general" room a special case', ->
      pinyins = Immutable.List(['general'])
      query = 'gonggaoban' # Search by chinese name
      index = @search.indexOfPinyins(pinyins, query)
      expect(index).toEqual 0
