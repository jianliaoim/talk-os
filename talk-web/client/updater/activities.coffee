
Immutable = require 'immutable'

exports.read = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  activities = actionData.get 'activities'

  if store.hasIn(['activities', _teamId])
    store.updateIn ['activities', _teamId], (oldActivities) ->
      oldActivities.concat activities
  else
    store.setIn ['activities', _teamId], activities

exports.remove = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _activityId = actionData.get('_id')

  store.updateIn ['activities', _teamId], (activities) ->
    if activities?
      activities.filterNot (activity) ->
        activity.get('_id') is _activityId
    else activities

exports.create = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _activityId = actionData.get('_id')

  store.updateIn ['activities', _teamId], (activities) ->
    if activities?
      activities.unshift actionData
    else activities

exports.update = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _activityId = actionData.get('_id')

  store.updateIn ['activities', _teamId], (activities) ->
    if activities?
      activities.map (activity) ->
        if activity.get('_id') is _activityId
          activity.merge actionData
        else
          activity
    else activities
