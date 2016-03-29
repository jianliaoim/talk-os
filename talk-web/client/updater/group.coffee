
exports.read = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  groups = actionData.get('groups')

  if store.hasIn ['groups', _teamId]
    store.mergeIn ['groups', _teamId], groups
  else
    store.setIn ['groups', _teamId], groups

exports.create = (store, actionData) ->
  _teamId = actionData.get('_teamId')

  store
  .updateIn ['groups', _teamId], (groups) ->
    # if exists somehow
    groups.push actionData

exports.update = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _groupId = actionData.get('_id')

  store
  .updateIn ['groups', _teamId], (groups) ->
    groups.map (group) ->
      if group.get('_id') is _groupId
        group.merge actionData
      else
        group

exports.remove = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _groupId = actionData.get('_id')

  store
  .updateIn ['groups', _teamId], (groups) ->
    groups.filterNot (group) ->
      group.get('_id') is _groupId
