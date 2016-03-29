
Immutable = require 'immutable'
emptyMap = Immutable.Map()
emptyList = Immutable.List()

exports.reload = (store) ->
  store
  .setIn ['device', 'disconnection'], false

exports.disconnect = (store) ->
  store
  .setIn ['device', 'disconnection'], true

exports.loading = (store, loadingInfo) ->
  store.updateIn ['device', 'loadingStack'], (stack) ->
    stack.push loadingInfo

exports.loaded = (store, loadingInfo) ->
  store.updateIn ['device', 'loadingStack'], (stack) ->
    stack.filterNot (info) ->
      info.get('_id') is loadingInfo.get('_id')

exports.markTeam = (store, _teamId) ->
  store.setIn ['device', '_teamId'], _teamId

exports.viewAttachment = (store, _attachmentId) ->
  store.setIn ['device', 'viewingAttachment'], _attachmentId

exports.tuned = (store, tuned) ->
  store.setIn ['device', 'isTuned'], tuned

exports.detectFocus = (store, status) ->
  store.setIn ['device', 'isFocused'], status

exports.markChannel = (store, channel) ->
  store.setIn [ 'device', 'lastChannel' ], channel

exports.clearingUnread = (store, data) ->
  _teamId = data.get('_teamId')
  _channelId = data.get('_channelId')
  isClearing = data.get('isClearing')
  store.setIn [ 'device', 'isClearingUnread', _teamId, _channelId ], isClearing

exports.updateInboxLoadStatus = (store, data) ->
  _teamId = data.get '_teamId'
  loadStatus = data.get 'loadStatus'

  store.setIn ['device', 'inboxLoadStatus', _teamId], loadStatus

exports.setEditMessageId = (store, data) ->
  store.setIn ['device', 'editMessageId'], data.get('_id')
