
Immutable = require 'immutable'
time = require '../util/time'
purifySchema = require '../util/purify-schema'

# dataSchema =
#   type: 'object'
#   properties:
#     _teamId: {type: 'string'}
#     _targetId: {type: 'string'}

purifyTeam = purifySchema.team

# when I'm invited into other teams
# member object: http://talk.ci/doc/event/team.join.html
exports.join = (store, contactData) ->
  _teamId = contactData.get('_teamId')
  _contactId = contactData.get('_id')
  _userId = store.getIn ['user', '_id']
  teamData = contactData.get 'team'
  inCollection = (contact) ->
    contact.get('_id') is _contactId

  topics = store.getIn ['topics', _teamId]
  if topics?
    generalRoom = topics
    .find (room) -> room.get('isGeneral')
    _generalRoomId = generalRoom.get '_id'
  else
    _generalRoomId = null

  store
  .update 'contacts', (cursor) ->
    if cursor.get(_teamId)?
      if cursor.get(_teamId).some(inCollection)
        cursor
      else if not contactData.get('isInvite')
        cursor.update _teamId, (contacts) ->
          contacts.push contactData
      else cursor
    else cursor
  .update 'leftContacts', (cursor) ->
    if cursor.get(_teamId)?
      cursor.update _teamId, (contacts) ->
        contacts.filterNot (contact) -> contact.get('_id') is _contactId
    else
      cursor
  .update 'members', (cursor) ->
    if cursor.getIn([_teamId, _generalRoomId])?
      cursor.updateIn [_teamId, _generalRoomId], (members) ->
        if members.some(inCollection) or contactData.get('isInvite')
          members
        else
          members.unshift contactData
    else cursor
  .update 'invitations', (cursor) ->
    if contactData.get('isInvite')
      if cursor.get(_teamId)?
        if cursor.get(_teamId).some(inCollection)
          cursor
        else
          cursor.update _teamId, (invitations) ->
            invitations.push contactData
    else cursor

exports.fetch = (store, teamList) ->
  store.update 'teams', (cursor) ->
    teamList.reduce (acc, teamData) ->
      _teamId = teamData.get('_id')
      if acc.get(_teamId)?
        acc.update _teamId, (oldTeam) ->
          oldTeam.merge teamData
      else
        acc.set _teamId, teamData
    , cursor

# dataSchema =
#   type: 'object'
#   properties:
#     _teamId: {type: 'string'}
#     _userId: {type: 'string'}
exports.leave = (store, leaveData) ->
  _teamId = leaveData.get '_teamId'
  _contactId = leaveData.get '_userId'
  _userId = store.getIn ['user', '_id']

  if _contactId is _userId
    store
    .update 'contacts', (cursor) ->
      cursor.delete _teamId
    .update 'members', (cursor) ->
      cursor.delete _teamId
    .update 'teams', (cursor) ->
      cursor.delete _teamId
    .update 'topics', (cursor) ->
      cursor.delete _teamId
    .setIn ['prefs', '_latestTeamId'], null

  else
    store
    .update 'contacts', (cursor) ->
      if cursor.get(_teamId)?
        cursor.update _teamId, (contacts) ->
          contacts.filter (contact) ->
            contact.get('_id') isnt _contactId
      else cursor
    .update 'members', (cursor) ->
      if cursor.get(_teamId)?
        cursor.update _teamId, (innerCursor) ->
          innerCursor.map (members) ->
            members.filterNot (member) ->
              member.get('_id') is _contactId
      else cursor

exports.create = (store, teamData) ->
  _teamId = teamData.get('_id')

  store.setIn ['teams', _teamId], purifyTeam(teamData)

exports.update = (store, teamData) ->
  _teamId = teamData.get('_id')

  store.updateIn ['teams', _teamId], (team) ->
    team.merge teamData

exports.removeInvite = (store, contactData) ->
  _teamId = contactData.get('_teamId')
  _contactId = contactData.get('_id')
  inCollection = (contact) ->
    contact.get('_id') is _contactId

  store
  .update 'invitations', (cursor) ->
    if contactData.get('isInvite')
      if cursor.get(_teamId)?
        if cursor.get(_teamId).some(inCollection)
          cursor.update _teamId, (invitations) ->
            invitations.filterNot (invitation) -> contactData.get('_id') is invitation.get('_id')
        else
          cursor
    else cursor

exports.getThirds = (store, data) ->
  refer = data.get('refer')
  teams = data.get('teams')

  store
  .update 'thirdParties', (cursor) ->
    cursor.set refer, teams

exports.syncOne = (store, teamData) ->
  _teamId = teamData.get('_id')
  store
  .update 'teams', (cursor) ->
    if cursor.has(_teamId)
      cursor.update _teamId, (oldTeam) ->
        oldTeam.merge teamData
    else
      cursor.set _teamId, teamData

exports.teamTopics = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  rooms = actionData.get 'data'

  store
    .setIn ['topics', _teamId], rooms
    .update 'topicPrefs', (cursor) ->
      rooms.reduce (acc, room) ->
        _roomId = room.get('_id')
        prefs = room.get('prefs') or Immutable.fromJS
          hideMobile: false
        acc.setIn [_teamId, _roomId], prefs
      , cursor

exports.teamMembers = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  members = actionData.get 'data'

  store
    .setIn ['contacts', _teamId], members
    .update 'contactPrefs', (cursor) ->
      members.reduce (acc, member) ->
        _contactId = member.get('_id')
        acc.setIn [_teamId, _contactId], member.get('prefs')
      , cursor

exports.teamInvitations = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  invitations = actionData.get 'data'

  store
    .setIn ['invitations', _teamId], invitations

exports.subscribed = (store, data) ->
  store.setIn ['teamSubscribe', data.get('_teamId')], true
