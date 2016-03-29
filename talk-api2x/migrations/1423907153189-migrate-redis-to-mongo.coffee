{redis, limbo} = require '../lib/components'
Promise = require 'bluebird'
{
  UserRuntimeModel
} = limbo.use 'talk'

exports.up = (next) ->
  unreadPromise = redis.keysAsync 'c:u:*'
  .each (key) ->
    parts = key.split(':')
    _userId = parts[2]
    _teamId = parts[4]
    return unless _userId and _teamId
    redis.hgetallAsync key
    .then (unreads) ->
      return unless unreads
      Promise.each Object.keys(unreads), (_targetId) ->
        unread = unreads[_targetId]
        console.log 'save unread num', _userId, _teamId, _targetId, unread
        conditions = _id: _userId
        update = {}
        update["unreadNums.#{_teamId}.#{_targetId}"] = Number(unread)
        options = upsert: true
        UserRuntimeModel.updateAsync conditions, update, options

  # lrmi:#{_userId}:t:#{_teamId}
  latestReadMessageIdPromise = redis.keysAsync 'lrmi:*'
  .each (key) ->
    parts = key.split ':'
    _userId = parts[1]
    _teamId = parts[3]
    return unless _userId and _teamId
    redis.hgetallAsync key
    .then (latestReadMessageIds) ->
      return unless latestReadMessageIds
      Promise.each Object.keys(latestReadMessageIds), (_targetId) ->
        _latestReadMessageId = latestReadMessageIds[_targetId]
        console.log 'save latest read message id', _userId, _teamId, _targetId, _latestReadMessageId
        UserRuntimeModel.saveLatestReadMessageIdAsync _userId, _teamId, _targetId, _latestReadMessageId

  # pt:#{_userId}:t:#{_teamId}
  pinnedAtPromise = redis.keysAsync 'pt:*'
  .each (key) ->
    parts = key.split ':'
    _userId = parts[1]
    _teamId = parts[3]
    return unless _userId and _teamId
    redis.hgetallAsync key
    .then (pinnedAts) ->
      return unless pinnedAts
      Promise.each Object.keys(pinnedAts), (_targetId) ->
        pinnedAt = Number(pinnedAts[_targetId])
        return unless pinnedAt
        console.log 'save pinned at', _userId, _teamId, _targetId, pinnedAt
        conditions = _id: _userId
        update = {}
        update["pinnedAts.#{_teamId}.#{_targetId}"] = pinnedAt
        options = upsert: true
        UserRuntimeModel.updateAsync conditions, update, options

  Promise.all [unreadPromise, latestReadMessageIdPromise, pinnedAtPromise]
  .then -> next()
  .catch next

exports.down = (next) ->
  next()
