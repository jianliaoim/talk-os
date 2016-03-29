
type = require 'type-of'

exports.isString = (x) ->
  (type x) is 'string'

exports.isNumber = (x) ->
  (type x) is 'number'

exports.isArray = (x) ->
  (type x) is 'array'

exports.isObject = (x) ->
  (type x) is 'object'

exports.isBoolean = (x) ->
  (type x) is 'boolean'

exports.isNull = (x) ->
  (type x) is 'null'

exports.isUndefined = (x) ->
  (type x) is 'undefined'

exports.isFunction = (x) ->
  (type x) is 'function'

exports.isElement = (x) ->
  (type x) is 'element'
