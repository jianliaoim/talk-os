dispatcher = require '../dispatcher'

dropUndefinedProps = (obj) ->
  newObj = {}
  Object.keys(obj).forEach (key) ->
    if obj[key]?
      newObj[key] = obj[key]
    else
      console.warn "Contains undefined value: #{key}"
  newObj

exports.go = (info) ->
  dispatcher.handleViewAction
    type: 'router/go'
    data:
      name: info.name
      data: dropUndefinedProps(info.data or {})
      query: dropUndefinedProps(info.query or {})

exports.team = (_teamId, searchQuery) ->
  exports.go
    name: 'team'
    data: {_teamId}
    query: searchQuery

exports.room = (_teamId, _roomId, searchQuery) ->
  exports.go
    name: 'room'
    data: {_teamId, _roomId}
    query: searchQuery

exports.chat = (_teamId, _toId, searchQuery) ->
  exports.go
    name: 'chat'
    data: {_teamId, _toId}
    query: searchQuery

exports.story = (_teamId, _storyId, searchQuery) ->
  data = { _teamId, _storyId }

  exports.go
    name: 'story'
    data: data
    query: searchQuery

exports.collection = (_teamId, searchQuery) ->
  exports.go
    name: 'collection'
    data: {_teamId}
    query: searchQuery

exports.favorites = (_teamId, searchQuery) ->
  exports.go
    name: 'favorites'
    data: {_teamId}
    query: searchQuery

exports.tags = (_teamId, searchQuery) ->
  exports.go
    name: 'tags'
    data: {_teamId}
    query: searchQuery

exports.settingRookie = ->
  exports.go
    name: 'setting-rookie'
    data: {}
    query: {}

exports.settingTeams = ->
  exports.go
    name: 'setting-teams'
    data: {}
    query: {}

exports.profile = (searchQuery) ->
  exports.go
    name: 'profile'
    data: {}
    query: searchQuery

exports.teamCreate = ->
  exports.go
    name: 'setting-team-create'
    data: {}
    query: {}

exports.teamSync = ->
  exports.go
    name: 'setting-sync'
    data: {}
    query: {}

exports.teamSyncList = ->
  exports.go
    name: 'setting-sync-teams'
    data: {}
    query: {}

exports.settingHome = ->
  exports.go
    name: 'setting-home'
    data: {}
    query: {}

exports.guestDisabled = ->
  exports.go
    name: 'disabled'
    data: {}
    query: {}

exports.guestRoom = (_roomId) ->
  exports.go
    name: 'room'
    data:
      _roomId: _roomId
    query: {}

exports.guestSignup = ->
  exports.go
    name: 'signup'
    data: {}
    query: {}

exports.guest404 = ->
  exports.go
    name: '404'
    data: {}
    query: {}

exports.mentions = (params, searchQuery) ->
  exports.go
    name: 'mentions'
    data: params
    query: searchQuery
