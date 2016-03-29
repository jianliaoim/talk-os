Immutable = require 'immutable'
emojisCategory = require '../util/emojis-category'

emojis =
  Immutable.fromJS(emojisCategory)
    .toList()
    .flatten()
    .sort()
    .toJS()

module.exports = emojis
