
exports.update = (store, actionData) ->
  store.update 'settings', (settings) ->
    settings.merge actionData

exports.teamFootprints = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  time = actionData.get('time')

  store.setIn ['settings', 'teamFootprints', _teamId], time

# dataSchema =
#   _teamId: {type: 'string'}
#   _id: {type: 'string'}
exports.foldContact = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _contactId = actionData.get('_id')

  store.setIn ['settings', 'foldedContacts', _teamId, _contactId], true

exports.unfoldContact = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _contactId = actionData.get('_id')

  store.setIn ['settings', 'foldedContacts', _teamId, _contactId], false

exports.markLogin = (store, status) ->
  store.setIn ['settings', 'isLoggedIn'], status

exports.openDrawer = (store, actionData) ->
  type = actionData.get 'type'

  store.setIn [ 'settings', 'showDrawer' ], type

exports.closeDrawer = (store) ->
  store.setIn [ 'settings', 'showDrawer' ], false

exports.changeEnterMethod = (store, method) ->
  store.setIn [ 'settings', 'enterMethod' ], method

exports.updateEmojiCounts = (store, emoji) ->
  store = store.updateIn [ 'settings', 'emojiCounts', emoji ], (count) ->
    (count or 0) + 1

  # normalize counts so the most recent emojis can be shown
  minCount = Math.min.apply(null, store.getIn(['settings', 'emojiCounts']).toList().toJS())
  store.updateIn ['settings', 'emojiCounts'], (emojis) ->
    emojis.map (count) ->
      count - minCount
