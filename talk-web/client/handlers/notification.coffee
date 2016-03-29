recorder = require 'actions-recorder'
dispatcher = require '../dispatcher'
unreadHandler = require './unread'

exports.update = (data) ->
  store = recorder.getState()
  isTuned = store.getIn ['device', 'isTuned']
  isFocused = store.getIn ['device', 'isFocused']
  routerData = store.getIn ['router', 'data']
  _channelId = routerData.get('_roomId') or routerData.get('_toId') or routerData.get('_storyId')
  isReading = isTuned and isFocused and data.get('_targetId') is _channelId
  hasMoreUnread = data.get('unreadNum') > data.get('oldUnreadNum')

  dispatcher.handleServerAction {type: 'notification/update', data}
  if isReading and hasMoreUnread
    unreadHandler.simulateRead()

exports.remove = (data) ->
  dispatcher.handleServerAction {type: 'notification/remove', data}
