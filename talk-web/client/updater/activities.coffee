moment = require 'moment'
Immutable = require 'immutable'

{ ACTIVITIES_READ_LIMIT } = require '../actions/activities'

transformActivities = (activities) ->
  activities
    .groupBy (v) ->
      current = moment(v.get('createdAt'))
      "#{current.year()}+#{current.month()}"
    .reduce (r, v, k) ->
      [year, month] = k.split '+'
      r.push Immutable.Map
        display: moment().year(year).month(month).format('Y MMM')
        data: v
    , Immutable.List()

exports.loading = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  direction = actionData.get 'direction'

  upDirection = store.getIn ['activities', _teamId, 'stage', 0]
  if direction is 'up'
    upDirection = 'loading'

  downDirection = store.getIn ['activities', _teamId, 'stage', 1]
  if direction is 'down'
    downDirection = 'loading'

  store.setIn ['activities', _teamId, 'stage'], Immutable.List [upDirection, downDirection]

exports.initial = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  activities = actionData.get 'activities'

  isComplete = activities.size < ACTIVITIES_READ_LIMIT

  store
    .setIn ['activities', _teamId, 'stage'], Immutable.List ['complete', if isComplete then 'complete' else 'partial']
    .updateIn ['activities', _teamId, 'data'], (prevData) ->
      data = prevData or Immutable.List()
      data
        .concat activities
        .toSet().toList()
        .sortBy (x) -> x.get 'createdAt'
        .reverse()
    .updateIn ['activities', _teamId], (state) ->
      state
        .set 'transformedData', transformActivities state.get 'data'

exports.read = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  direction = actionData.get 'direction'
  activities = actionData.get 'activities'

  isComplete = activities.size < ACTIVITIES_READ_LIMIT

  upDirection = store.getIn ['activities', _teamId, 'stage', 0]
  if direction is 'up'
    upDirection = if isComplete then 'complete' else 'partial'

  downDirection = store.getIn ['activities', _teamId, 'stage', 1]
  if direction is 'down'
    downDirection = if isComplete then 'complete' else 'partial'

  store
    .setIn ['activities', _teamId, 'stage'], Immutable.List [upDirection, downDirection]
    .updateIn ['activities', _teamId, 'data'], (prevData) ->
      data = prevData or Immutable.List()
      data
        .concat activities
        .toSet().toList()
        .sortBy (x) -> x.get 'createdAt'
        .reverse()
    .updateIn ['activities', _teamId], (state) ->
      state
        .set 'transformedData', transformActivities state.get 'data'

exports.replace = (store, actionData) ->
  _teamId = actionData.get '_teamId'
  activities = actionData.get 'activities'

  store
    .setIn ['activities', _teamId, 'stage'], Immutable.List ['partial', 'partial']
    .updateIn ['activities', _teamId, 'data'], (prevData) ->
      Immutable.List()
        .concat activities
        .sortBy (x) -> x.get 'createdAt'
        .reverse()
    .updateIn ['activities', _teamId], (state) ->
      state
        .set 'transformedData', transformActivities state.get 'data'

exports.remove = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _activityId = actionData.get('_id')

  store.updateIn ['activities', _teamId, 'data'], (activities) ->
    if activities?
      activities.filterNot (activity) ->
        activity.get('_id') is _activityId
    else activities

exports.create = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _activityId = actionData.get('_id')

  store.updateIn ['activities', _teamId, 'data'], (activities) ->
    if activities?
      activities.unshift actionData
    else activities

exports.update = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _activityId = actionData.get('_id')

  store.updateIn ['activities', _teamId, 'data'], (activities) ->
    if activities?
      activities.map (activity) ->
        if activity.get('_id') is _activityId
          activity.merge actionData
        else
          activity
    else activities
