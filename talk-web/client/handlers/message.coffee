assign = require 'object-assign'
recorder = require 'actions-recorder'

query = require '../query'
eventBus = require '../event-bus'
dispatcher = require '../dispatcher'

messageActions = require '../actions/message'

notifyActions = require '../actions/notify'

lang = require '../locales/lang'

find = require '../util/find'
lookup = require '../util/lookup'
dom = require '../util/dom'

# http://talk.ci/doc/event/message.create.html
exports.create = (messageData) ->
  store = recorder.getState()
  isTuned = store.getIn ['device', 'isTuned']
  isFocused = store.getIn ['device', 'isFocused']
  _userId = store.getIn ['user', '_id']

  isReading = false

  if isTuned and isFocused
    _teamId = messageData.get('_teamId')
    _roomId = messageData.get('_roomId')
    _toId = messageData.get('_toId')
    _storyId = messageData.get('_storyId')
    if _toId is _userId
      _toId = messageData.get '_creatorId'

    routerData = store.getIn ['router', 'data']
    currentTeamId = routerData.get('_teamId')
    currentRoomId = routerData.get('_roomId')
    currentToId = routerData.get('_toId')
    currentStoryId = routerData.get('_storyId')
    if currentTeamId is _teamId
      if _roomId? and currentRoomId is _roomId
        isReading = true
      else if _toId? and currentToId is _toId
        isReading = true
      else if _storyId? and currentStoryId is _storyId
        isReading = true

  dispatcher.handleServerAction
    type: 'message/create'
    data: messageData

  if isReading
    eventBus.emit 'dirty-action/new-message'
    eventBus.emit 'dirty-action/focus-box'
    messageActions.receipt messageData, _userId

# http://talk.ci/doc/event/message.remove.html
exports.remove = (actionData) ->
  _toId = actionData.get '_toId'
  _roomId = actionData.get '_roomId'
  _teamId = actionData.get '_teamId'
  _storyId = actionData.get '_storyId'
  _messageId = actionData.get '_id'

  _channelId = _toId or _roomId or _storyId

  store = recorder.getState()
  viewingAttachment = store.getIn ['device', 'viewingAttachment']
  if viewingAttachment?
    maybeMessage = store.getIn(['messages', _teamId, _channelId])?.find (message) ->
      message.get('_id') is _messageId
    if maybeMessage?
      maybyAttachment = maybeMessage.get('attachments').find (attachment) ->
        attachment.get('_id') is viewingAttachment
      if maybyAttachment?
        notifyActions.info lang.getText('message-deleted')

  dispatcher.handleServerAction
    type: 'message/remove'
    data: actionData

exports.checkUnreadMentions = ->
  scrollerNode = document.querySelector('.message-area .scroller')
  return if not scrollerNode

  unreadsNode = document.querySelector('.message-timeline')?.querySelectorAll('.is-unread')
  return if not unreadsNode

  store = recorder.getState()
  routerData = store.getIn ['router', 'data']
  _userId = store.getIn ['user', '_id']
  _teamId = routerData.get('_teamId')
  _channelId = lookup.getChannelId(routerData)

  for node in unreadsNode
    if dom.isElementInViewport(node, scrollerNode)
      messageId = node.getAttribute('data-message-id')
      message = query.messagesBy(store, _teamId, _channelId).find (m) -> m.get('_id') is messageId
      if message
        messageActions.receipt(message, _userId)
