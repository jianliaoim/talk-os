recorder = require 'actions-recorder'

dispatcher = require '../dispatcher'

exports.markTeam = (_teamId) ->
  dispatcher.handleViewAction
    type: 'device/mark-team'
    data: _teamId

exports.markChannel = (channel) ->
  dispatcher.handleViewAction
    type: 'device/mark-channel'
    data: channel

exports.networkReload = ->
  dispatcher.handleViewAction
    type: 'device/reload'

exports.networkDisconnect = ->
  dispatcher.handleViewAction
    type: 'device/disconnect'

exports.networkLoading = (loadingInfo) ->
  dispatcher.handleViewAction
    type: 'device/loading'
    data: loadingInfo

exports.networkLoaded = (loadingInfo) ->
  dispatcher.handleViewAction
    type: 'device/loaded'
    data: loadingInfo

exports.viewAttachment = (_attachmentId) ->
  dispatcher.handleViewAction
    type: 'device/view-attachment'
    data: _attachmentId

exports.tuned = (tuned) ->
  store = recorder.getStore()

  status = store.getIn ['device', 'isTuned']
  if tuned isnt status
    dispatcher.handleViewAction
      type: 'device/tuned'
      data: tuned

exports.detectFocus = (status) ->
  dispatcher.handleViewAction
    type: 'device/detect-focus'
    data: status

exports.clearingUnread = (_teamId, _channelId, isClearing) ->
  dispatcher.handleViewAction
    type: 'device/clearing-unread'
    data:
      _teamId: _teamId
      _channelId: _channelId
      isClearing: isClearing

exports.updateInboxLoadStatus = (_teamId, loadStatus) ->
  dispatcher.handleViewAction
    type: 'device/update-inbox-load-status'
    data:
      _teamId: _teamId
      loadStatus: loadStatus

exports.setEditMessageId = (_id) ->
  dispatcher.handleViewAction
    type: 'device/set-edit-message-id'
    data:
      _id: _id
