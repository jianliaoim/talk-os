describe 'util: time', ->

  beforeEach ->
    @time = require 'util/time'

  describe 'function: notSameDay', ->
    it 'should return false if two dates are the same day', ->
      a = '2016-01-18T09:11:50.746Z'
      b = '2016-01-18T09:11:50.746Z'
      expect(@time.notSameDay(a, b)).toEqual false

    it 'should return true if two dates are not the same day', ->
      a = '2016-01-18T09:11:50.746Z'
      b = '2016-01-19T09:11:50.746Z'
      expect(@time.notSameDay(a, b)).toEqual true

    it 'should return true if two dates are not the same month', ->
      a = '2016-01-18T09:11:50.746Z'
      b = '2016-02-18T09:11:50.746Z'
      expect(@time.notSameDay(a, b)).toEqual true

    it 'should return true if two dates are not the same month', ->
      a = '2016-01-18T09:11:50.746Z'
      b = '2017-02-18T09:11:50.746Z'
      expect(@time.notSameDay(a, b)).toEqual true

    it 'should return invald data', ->
      a = ''
      b = '2017-02-18T09:11:50.746Z'
      expect(@time.notSameDay(a, b)).toEqual true

      a = ''
      b = ''
      expect(@time.notSameDay(a, b)).toEqual true
