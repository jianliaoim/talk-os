
Immutable = require 'immutable'

exports.clear = (store, actionData) ->
  store.set 'bannerNotices', Immutable.Map()

exports.create = (store, noticeData) ->
  store.set 'bannerNotices', noticeData
