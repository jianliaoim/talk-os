Immutable = require 'immutable'

describe 'util: search', ->

  beforeEach ->
    @pinyin = require 'util/pinyin'

  describe 'function: make', ->
    it 'should make pinyin', ->
      expect(@pinyin.make('测试')).toEqualImmutable Immutable.fromJS {
        pinyin: 'ceshi'
        pinyins: ['ceshi']
        py: 'cs'
        pys: ['cs']
      }

    it 'should make heteronym', ->
      expect(@pinyin.make('了甸')).toEqualImmutable Immutable.fromJS {
        pinyin: 'ledian'
        pinyins: ['ledian', 'liaodian', 'letian', 'liaotian', 'lesheng', 'liaosheng', 'lesheng', 'liaosheng']
        py: 'ld'
        pys: ['ld', 'lt', 'ls', 'ls']
      }

    it 'should make heteronym and make unique', ->
      expect(@pinyin.make('了了了')).toEqualImmutable Immutable.fromJS {
        pinyin: 'lelele'
        pinyins: ['lelele', 'liaolele', 'leliaole', 'liaoliaole', 'leleliao', 'liaoleliao', 'leliaoliao', 'liaoliaoliao']
        py: 'lll'
        pys: ['lll']
      }

    it 'should handle falsy values', ->
      expect(@pinyin.make(undefined)).toEqual undefined
      expect(@pinyin.make('')).toEqual undefined

    it 'should handle english words', ->
      expect(@pinyin.make('test word')).toEqualImmutable Immutable.fromJS {
        pinyin: 'test word'
        pinyins: ['test word']
        py: 'test word'
        pys: ['test word']
      }
