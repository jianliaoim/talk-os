
exports.update = (store, prefsData) ->
  store
    .set 'prefs', prefsData
    .setIn ['user', 'preference'], prefsData
