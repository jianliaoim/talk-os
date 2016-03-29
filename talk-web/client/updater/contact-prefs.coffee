
exports.push = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _contactId = actionData.get('_userId')

  prefsData = actionData
  .delete '_teamId'
  .delete '_userId'

  store.update 'contactPrefs', (cursor) ->
    if cursor.getIn([_teamId, _contactId])?
      cursor.updateIn [_teamId, _contactId], (prefs) ->
        prefs.merge prefsData
    else cursor

# API is under namespace `team`, gets team object
exports.update = (store, actionData) ->
  prefsData = actionData.get('resp').get('prefs')
  _teamId = actionData.get('resp').get('_id')
  _contactId = actionData.get('_userId')

  store.update 'contactPrefs', (cursor) ->
    if cursor.getIn([_teamId, _contactId])?
      cursor.updateIn [_teamId, _contactId], (prefs) ->
        prefs.merge prefsData
    else cursor
