
recorder = require 'actions-recorder'

query = require '../query'

dataRely = require '../network/data-rely'

deviceActions = require '../actions/device'
settingsActions = require '../actions/settings'

exports.update = (prefs) ->
  store = recorder.getState()

  # skips sending request when another request is performing
  return if store.getIn(['device', 'loadingStack']).size > 0

  _userId = query.userId(store)
  _teamId = store.getIn ['router', 'data', '_teamId']
  _roomId = store.getIn ['router', 'data', '_roomId']
  _toId = store.getIn ['router', 'data', '_toId']
  sort = createdAt: {order: "desc"}

  if _roomId?
    searchData = {_teamId, _roomId, sort, limit: 20}
  else if _toId?
    _toIds = _creatorIds = [_userId, _toId]
    searchData = {_teamId, _creatorIds, _toIds, sort, isDirectMessage: true, limit: 20}

  tagSearchData =
    _teamId: _teamId
    hasTag: true
    limit: 20
    sort: sort
    _userId: _userId
  if _roomId?
    tagSearchData._roomId = _roomId
  else if _toId?
    tagSearchData.isDirectMessage = true
    tagSearchData._creatorIds = tagSearchData._toIds = [_toId, _userId]

  deps = [
    dataRely.relyFileMessages(searchData) if prefs.showCollection
    dataRely.relyLinkMessages(searchData) if prefs.showCollection
    dataRely.relyPostMessages(searchData) if prefs.showCollection
    dataRely.relySnippetMessages(searchData) if prefs.showCollection
    dataRely.relyFavorites(_teamId) if prefs.showFavorites
    dataRely.relyTaggedMessages(tagSearchData) if prefs.showTag
  ]

  info =
    type: 'draft'
  deviceActions.networkLoading(info)
  dataRely.ensure deps, ->
    settingsActions.update prefs
    deviceActions.networkLoaded(info)
