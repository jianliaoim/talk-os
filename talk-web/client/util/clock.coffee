Immutable = require 'immutable'
time      = require './time'

interval = 10 * 1000

functions = Immutable.Map()

if typeof window isnt 'undefined'
  clock = time.every interval, ->
    functions.forEach (fn) ->
      fn()

exports.add = (id, fn) ->
  functions = functions.set(id, fn)

exports.remove = (id, fn) ->
  functions = functions.delete(id)
