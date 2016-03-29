
Immutable = require 'immutable'

# dataSchema =
#   type: 'object'
#   properties:
#     _teamId: {type: 'string'}
#     _toId: {type: 'string'}
#     data:
#       type: 'array'
#       items: {} # array message objects
exports.fetch = (store, actionData) ->
  messageData = actionData.get('data')
  _teamId = actionData.get('_teamId')
  _channelId = actionData.get('_toId')

  if store.getIn(['messages', _teamId])?
    store.setIn ['messages', _teamId, _channelId], messageData
  else
    store.setIn ['messages', _teamId], Immutable.Map().set(_channelId, messageData)

# related API: http://talk.ci/doc/restful/team.removemember.html
# dataSchema =
#   type: 'object'
#   properties:
#     user: {type: 'object'}
#     _teamId: {type: 'string'}
exports.remove = (store, removeData) ->
  _teamId = removeData.get '_teamId'
  _contactId = removeData.getIn ['user', '_id']

  inCollection = (contact) ->
    contact.get('_id') is _contactId

  store
  .update 'contacts', (cursor) ->
    if cursor.has _teamId
      cursor.update _teamId, (contacts) ->
        contacts.filterNot(inCollection)
    else
      cursor
  .update 'leftContacts', (cursor) ->
    if cursor.has(_teamId) and not cursor.get(_teamId).some(inCollection)
      cursor.update _teamId, (contacts) ->
        contacts.push removeData.get('user').set('isQuit', true)

# http://talk.ci/doc/event/member.update.html
# http://talk.ci/doc/restful/team.setmemberrole.html
# dataSchema =
#    type: 'object'
#    properties:
#     _teamId: {type: 'string'}
#     _userId: {type: 'string'}
#     role: {type: 'string'}
exports.update = (store, roleData) ->
  _teamId = roleData.get '_teamId'
  _userId = roleData.get '_userId'

  if store.getIn(['contacts', _teamId])?
    store.updateIn ['contacts', _teamId], (contacts) ->
      contacts.map (contact) ->
        if contact.get('_id') is _userId
          # tricky, but by now it's the only purpose of the action
          contact.set 'role', roleData.get('role')
        else contact
  else store

# array of contact objects: http://talk.ci/doc/restful/team.members.html
# dataSchema =
#   type: 'object'
#   properties:
#     _teamId: {type: 'string'}
#     data:
#       type: 'array'
#       items:
#         type: 'object'
#         properties: {} # complicated
exports.fetchLeft = (store, leftContactsData) ->
  _teamId = leftContactsData.get('_teamId')
  contactListData = leftContactsData.get('data')

  store.setIn ['leftContacts', _teamId], contactListData.map (contact) ->
    contact.set 'isQuit', true

# teams.members.get
# http://talk.ci/doc/restful/team.members.html
exports.read = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  data = actionData.get 'data'

  if store.hasIn ['contacts', _teamId]
    store.mergeIn ['contacts', _teamId], data
  else
    store.setIn ['contacts', _teamId], data
