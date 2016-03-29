recorder = require 'actions-recorder'

eventBus = require '../event-bus'

time = require '../util/time'
query = require '../query'

notificationActions = require '../actions/notification'
lookup = require '../util/lookup'

messageHandler = require './message'

exports.clear = (noty) ->
  notificationActions.clearUnread noty
  window.requestAnimationFrame -> # 渲染完后再发送请求
    messageHandler.checkUnreadMentions()

exports.simulateRead = (triggerEvent = true) ->
  store = recorder.getState()
  routerData = store.getIn ['router', 'data']
  _teamId = routerData.get('_teamId')
  _channelId = lookup.getChannelId(routerData)
  _userId = store.getIn ['user', '_id']

  if _teamId? and _channelId?
    n = query.notificationsByOne(store, _teamId, _channelId)
    differentUnread = n.has('oldUnreadNum') and n.get('oldUnreadNum') isnt n.get('unreadNum')
    if differentUnread or n.get('unreadNum') > 0
      exports.clear(n)

    if triggerEvent
      eventBus.emit 'dirty-action/new-message'
      eventBus.emit 'dirty-action/focus-box'
