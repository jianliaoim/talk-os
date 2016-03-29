
Immutable = require 'immutable'

# room object: http://talk.ci/doc/restful/guest/room.join.html
exports.reset = (store, roomData) ->
  # force set unread to zero, ignore data from server
  roomData = roomData.set 'unread', 0

  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')
  membersData = roomData.get('members')
  messagesData = roomData.get('latestMessages')

  store
  .setIn ['members', _teamId, _roomId], membersData
  .updateIn ['topics', _teamId], (cursor) ->
    if cursor?
      cursor.map (topic) ->
        if topic.get('_id') is _roomId
          topic.merge roomData
        else topic
    else cursor
  .update 'messages', (messagesEntry) ->
    sortedMessages = messagesData.sortBy (message) ->
      message.get('createdAt')
    if messagesEntry.get(_teamId)?
      messagesEntry.setIn [_teamId, _roomId], sortedMessages
    else
      messagesEntry.set _teamId, (Immutable.Map().set _roomId, sortedMessages)

# http://talk.ci/doc/restful/guest/room.readone.html
exports.fetch = (store, roomData) ->
  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')

  topicsCollection =  Immutable.List [roomData]
  teamCollection = Immutable.Map().set _teamId, topicsCollection
  store.set 'topics', teamCollection

# http://talk.ci/doc/restful/message.clear.html
# example: {_roomId, _latestReadMessageId}
exports.clear = (store, data) ->
  _teamId = data.get('_teamId')
  _roomId = data.get('_roomId')
  _latestReadMessageId = data.get('_latestReadMessageId')
  store.updateIn ['topics', _teamId], (cursor) ->
    if cursor?
      cursor.map (topic) ->
        if topic.get('_id') is _roomId
          topic
          .set 'unread', 0
          .set '_latestReadMessageId', _latestReadMessageId
        else topic
    else cursor
