recorder = require 'actions-recorder'

lang = require '../locales/lang'
detect = require '../util/detect'
query = require '../query'
dispatcher = require '../dispatcher'
routerHanlders = require './router'
notifyActions = require '../actions/notify'

# http://talk.ci/doc/event/room.remove.html
exports.remove = (roomData) ->
  store = recorder.getState()
  router = store.get('router')
  currentTeamId = router.getIn ['data', '_teamId']
  currentRoomId = router.getIn ['data', '_roomId']

  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')

  if _teamId is currentTeamId and _roomId is currentRoomId
    generalRoom = query.topicsByOne store, currentTeamId
    routerHanlders.room _teamId, generalRoom.get('_id')
    warningText = lang.getText('topic-%s-removed')
    .replace '%s', roomData.get('topic')
    notifyActions.warn warningText

  # dispatching should happen in actions creator
  dispatcher.handleServerAction
    type: 'topic/remove'
    data: roomData

# http://talk.ci/doc/event/room.leave.html
exports.leave = (leaveEvent) ->
  _teamId = leaveEvent.get('_teamId')
  _roomId = leaveEvent.get('_roomId')
  _contactId = leaveEvent.get('_userId')

  store = recorder.getState()
  _userId = store.getIn ['user', '_id']
  routerData = store.getIn ['router', 'data']
  roomData = query.topicsByOne(store, _teamId, _roomId)
  currentTeamId = routerData.get('_teamId')
  currentRoomId = routerData.get('_roomId')

  if _contactId is _userId
    warningText = lang.getText('removed-from-topic-%s')
    .replace '%s', roomData.get('topic')
    notifyActions.warn warningText

    if roomData.get('isPrivate') and _roomId is currentRoomId
      generalRoom = query.topicsByOne store, currentTeamId
      routerHanlders.room currentTeamId, generalRoom.get('_id')

  # dispatching should happen in actions creator
  dispatcher.handleServerAction
    type: 'topic/leave'
    data: leaveEvent

# http://talk.ci/doc/event/room.archive.html
exports.archive = (roomData) ->
  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')

  store = recorder.getState()
  routerData = store.getIn ['router', 'data']
  currentTeamId = routerData.get('_teamId')
  currentRoomId = routerData.get('_roomId')

  if roomData.get('isArchived') and _teamId is currentTeamId
    warningText = lang.getText('topic-%s-archived')
    .replace '%s', roomData.get('topic')
    notifyActions.info warningText

  if currentRoomId is _roomId
    generalRoom = query.topicsByOne store, currentTeamId
    routerHanlders.room currentTeamId, generalRoom.get('_id')

  dispatcher.handleServerAction
    type: 'topic/archive',
    data: roomData

# http://talk.ci/doc/event/room.update.html
exports.update = (roomData) ->
  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')

  store = recorder.getState()
  routerData = store.getIn ['router', 'data']
  currentTeamId = routerData.get '_teamId'
  currentRoomId = routerData.get '_roomId'
  localRoomData = query.topicsByOne store, _teamId, _roomId

  if roomData.get('isPrivate') and not detect.inChannel(localRoomData) and currentRoomId is _roomId
    generalRoom = query.topicsByOne store, currentTeamId
    routerHanlders.room currentTeamId, generalRoom.get('_id')
    warningText = lang.getText('topic-%s-changed-private')
    .replace '%s', roomData.get('topic')
    notifyActions.warn warningText

  dispatcher.handleServerAction
    type: 'topic/update'
    data: roomData
