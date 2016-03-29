
# http://talk.ci/doc/event/room.prefs.update.html
# dataSchema =
#   type: 'object'
#   properties:
#     _userId: {type: 'string'}
#     _roomId: {type: 'string'}
#     _teamId: {type: 'string'}
exports.push = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _roomId = actionData.get('_roomId')
  prefsData = actionData.delete('_teamId').delete('_roomId')

  store.update 'topicPrefs', (cursor) ->
    if cursor.get(_roomId)?
      cursor.update _roomId, (prefs) ->
        prefs.merge prefsData
    else cursor

# room object http://talk.ci/doc/restful/room.updateprefs.html
exports.update = (store, roomData) ->
  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')
  prefsData = roomData.get('prefs')

  store.update 'topicPrefs', (cursor) ->
    if cursor.getIn([_teamId, _roomId])?
      cursor.updateIn [_teamId, _roomId], (prefs) ->
        prefs.merge prefsData
    else cursor
