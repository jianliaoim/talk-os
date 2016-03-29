
Immutable = require 'immutable'

time = require '../util/time'
purifySchema = require '../util/purify-schema'

# this action handle: current use join a quitted room
# part of member object: http://talk.ci/doc/restful/room.invite.html
# `_teamId` must be guarenteed by program
# member data(in complete) http://talk.ci/doc/restful/room.invite.html
# may also be an object of user

purifyTopic = purifySchema.topic

exports.join = (store, specialMemberData) ->
  # `_teamId` must be guarenteened by program!
  _teamId = specialMemberData.get('_teamId')
  _roomId = specialMemberData.get('_roomId')
  _memberId = specialMemberData.get('_id')
  _userId = store.getIn ['user', '_id']
  isGuest = specialMemberData.get('isGuest')
  inCollection = (room) -> room.get('_id') is _roomId
  notInCollection = (contact) -> contact.get('_id') isnt _memberId

  store
  .update 'topics', (cursor) ->
    if cursor.get(_teamId)? and (_memberId is _userId)
      cursor.update _teamId, (rooms) ->
        if rooms.some(inCollection)
          rooms.map (room) ->
            if room.get('_id') is _roomId
              room.set('isQuit', false)
              .set('lastActive', time.nowISOString())
            else room
        else rooms
    else cursor
  .update 'contacts', (cursor) ->
    notIn = cursor.get(_teamId).every(notInCollection)
    if cursor.get(_teamId)? and not isGuest and notIn and not specialMemberData.get('isInvite')
      cursor.update _teamId, (contacts) ->
        contacts.push specialMemberData
    else cursor
  .update 'members', (cursor) ->
    if cursor.getIn([_teamId, _roomId])?
      notIn = cursor.getIn([_teamId, _roomId]).every(notInCollection)
      if notIn and not specialMemberData.get('isInvite')
        cursor.updateIn [_teamId, _roomId], (members) ->
          members.unshift specialMemberData
      else cursor
    else cursor
  .update 'invitations', (cursor) ->
    if cursor.get(_teamId)? and specialMemberData.get('isInvite')
      notIn = cursor.get(_teamId).every(notInCollection)
      if notIn
        cursor.update _teamId, (invitations) ->
          invitations.push specialMemberData
      else
        cursor.set _teamId, Immutable.List([specialMemberData])
    else cursor

# topic object: http://talk.ci/doc/restful/room.readone.html
exports.fetch = (store, roomData) ->
  membersData = roomData.get('members')
  _roomId = roomData.get('_id')
  _teamId = roomData.get('_teamId')

  visibleMessages = roomData.get('latestMessages') or Immutable.List()
  prefs = roomData.get('prefs') or Immutable.fromJS
    hideMobile: false

  store
  .update 'members', (cursor) ->
    cursor.setIn [_teamId, _roomId], membersData
  .update 'messages', (cursor) ->
    sortedMessage = visibleMessages.sortBy (message) -> message.get('createdAt')
    cursor.setIn [_teamId, _roomId], sortedMessage
  .update 'topicPrefs', (cursor) ->
    cursor.setIn [_teamId, _roomId], prefs

# http://talk.ci/doc/event/room.leave.html
# dataSchema =
#   type: 'object'
#   properties:
#     _teamId: {type: 'string'}
#     _roomId: {type: 'string'}
#     _userId: {type: 'string'}
exports.leave = (store, leaveData) ->
  _teamId = leaveData.get('_teamId')
  _roomId = leaveData.get('_roomId')
  _memberId = leaveData.get('_userId')
  _userId = store.getIn ['user', '_id']

  if _memberId is _userId
    store
    .update 'topics', (cursor) ->
      if cursor.has(_teamId)
        cursor.update _teamId, (rooms) ->
          rooms.map (room) ->
            if room.get('_id') is _roomId
              room.set('isQuit', true)
            else room
      else cursor
    .deleteIn ['topicPrefs', _teamId, _roomId]
    .update 'members', (cursor) ->
      cursor.deleteIn [_teamId, _roomId]
  else
    store
    .update 'members', (cursor) ->
      if cursor.getIn([_teamId, _roomId])?
        cursor.updateIn [_teamId, _roomId], (members) ->
          members.filterNot (member) ->
            member.get('_id') is _memberId
      else cursor

# room object: http://talk.ci/doc/event/room.update.html
exports.update = (store, roomData) ->
  # These properties are special, dont be undefined
  roomData = roomData
  .update 'guestUrl', (guestUrl) -> guestUrl or null
  .update 'guestToken', (guestToken) -> guestToken or null

  _id = roomData.get '_id'
  _teamId = roomData.get '_teamId'
  members = roomData.get 'members'

  store
  .update 'topics', (teams) ->
    if Immutable.List.isList teams.get _teamId
      teams.update _teamId, (rooms) ->
        isExistedId = (room) -> _id is room.get '_id'
        existIndex = rooms.findIndex isExistedId
        if existIndex > -1
          rooms.update existIndex, (room) ->
            room.merge roomData
        else
          rooms.push roomData
    else
      teams
  .update 'members', (teams) ->
    if Immutable.Map.isMap teams.get _teamId
      teams.update _teamId, (rooms) ->
        rooms.set _id, members
    else
      teams

# room object: http://talk.ci/doc/event/room.create.html
exports.create = (store, roomData) ->
  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_roomId')
  _userId = store.getIn ['user', '_id']
  isCreator = (roomData) -> roomData.get('_creatorId') is _userId
  inCollection = (room) -> room.get('_id') is _roomId

  if store.getIn(['topics', _teamId])?
    store.updateIn ['topics', _teamId], (rooms) ->
      if rooms.some(inCollection)
        rooms.map (room) ->
          if room.get('_id') is _roomId
            room.set 'isQuit', false
          else room
      else
        newRoom = roomData.set 'isQuit', not isCreator(roomData)
        rooms.unshift purifyTopic(newRoom)
  else store

# room object: http://talk.ci/doc/restful/room.archive.html
exports.archive = (store, roomData) ->
  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')
  isArchived = roomData.get('isArchived')
  inCollection = (room) -> room.get('_id') is _roomId

  store
  .update 'topics', (cursor) ->
    if cursor.get(_teamId)?
      if isArchived
        cursor.update _teamId, (rooms) ->
          rooms.filterNot inCollection
      else
        cursor.update _teamId, (rooms) ->
          if inCollection(rooms)
            rooms
          else
            rooms.unshift roomData
    else cursor
  .update 'archivedTopics', (cursor) ->
    if cursor.get(_teamId)?
      if isArchived
        cursor.update _teamId, (rooms) ->
          if inCollection(rooms)
            rooms
          else
            rooms.unshift roomData
      else
        cursor.update _teamId, (rooms) ->
          rooms.filterNot inCollection
    else cursor

# dataSchema =
#   type: 'object'
#   properties:
#     _teamId: {type: 'string'}
#     data:
#       type: 'array'
#       items: {} # array of rooms, complicated
exports.resetArchived = (store, resetArchivedData) ->
  _teamId = resetArchivedData.get('_teamId')
  archivedRoomsList = resetArchivedData.get('data')

  store.update 'archivedTopics', (cursor) ->
    cursor.set _teamId, archivedRoomsList

# member data: http://talk.ci/doc/event/room.join.html
exports.invite = (store, memberData) ->
  roomData = memberData.get('room')
  _teamId = memberData.get('_teamId')
  _roomId = memberData.get('_roomId')
  _memberId = memberData.get('_id')
  isGuest = memberData.get('isGuest')
  _userId = store.getIn ['user', '_id']
  inCollection = (room) -> room.get('_id') is _roomId
  notInCollection = (contact) -> contact.get('_id') isnt _memberId

  store
  .update 'topics', (cursor) ->
    if (_memberId is _userId) and cursor.get(_teamId)? and roomData?
      cursor.update _teamId, (rooms) ->
        if rooms.some(inCollection)
          rooms.map (room) ->
            if room.get('_id') is _roomId
              room.set('isQuit', false)
              .set('lastActive', time.nowISOString())
            else room
        else
          rooms.unshift roomData
    else cursor
  .update 'contacts', (cursor) ->
    if cursor.get(_teamId)? and not isGuest
      if cursor.get(_teamId).every(notInCollection)
        cursor.update _teamId, (contacts) ->
          contacts.push memberData
      else cursor
    else cursor
  .update 'members', (cursor) ->
    if _teamId is store.getIn(['device', '_teamId']) and cursor.getIn([_teamId, _roomId])?
      if cursor.getIn([_teamId, _roomId]).every(notInCollection)
        cursor.updateIn [_teamId, _roomId], (members) ->
          members.unshift memberData
      else cursor
    else cursor

# room object: http://talk.ci/doc/restful/room.remove.html
exports.remove = (store, roomData) ->
  _teamId = roomData.get('_teamId')
  _roomId = roomData.get('_id')
  isArchived = roomData.get('isArchived')

  store
  .update 'topics', (cursor) ->
    if cursor.has _teamId
      cursor.update _teamId, (rooms) ->
        rooms.filterNot (room) ->
          room.get('_id') is _roomId
    else cursor
  .update 'archivedTopics', (cursor) ->
    if isArchived and cursor.has _teamId
      cursor.update _teamId, (rooms) ->
        rooms.filterNot (room) ->
          room.get('_id') is _roomId
    else cursor
  .update 'notifications', (cursor) ->
    if cursor.has _teamId
      cursor.update _teamId, (notifications) ->
        notifications.filterNot (notification) ->
          notification.getIn(['target', '_id']) is roomData.get('_id')
    else cursor

# dataSchema =
#   _teamId: {type: 'string'}
#   _roomId: {type: 'string'}
#   _userId: {type: 'string'}
# Different from API! https://jianliao.com/doc/restful/room.removemember.html
exports.removeMember = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _roomId = actionData.get('_roomId')
  _memberId = actionData.get('_userId')

  store
  .update 'members', (cursor) ->
    if cursor.getIn([_teamId, _roomId])?
      cursor.updateIn [_teamId, _roomId], (members) ->
        members.filterNot (member) ->
          member.get('_id') is _memberId
    else cursor
