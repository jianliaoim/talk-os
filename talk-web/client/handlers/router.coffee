recorder = require 'actions-recorder'
pathUtil = require 'router-view/lib/path'

query = require '../query'
routes = require '../routes'
eventBus = require '../event-bus'

lang = require '../locales/lang'

time = require '../util/time'
detect = require '../util/detect'
analytics = require '../util/analytics'
lazyModules = require '../util/lazy-modules'

teamActions = require '../actions/team'
prefsActions = require '../actions/prefs'
storyActions = require '../actions/story'
deviceActions = require '../actions/device'
notifyActions = require '../actions/notify'
routerActions = require '../actions/router'
accountActions = require '../actions/account'
messageActions = require '../actions/message'
settingsActions = require '../actions/settings'

unreadHandlers = require '../handlers/unread'

dataRely = require '../network/data-rely'

exports.room = (_teamId, _roomId, urlQuery={}, cb) ->
  store = recorder.getState()

  matchTopic = (topic) -> topic.get('_id') is _roomId
  targetTopic = store.getIn(['topics', _teamId])?.find(matchTopic)
  isTopicJoinded = targetTopic? and detect.inChannel(targetTopic)

  settings = query.settings(store)

  sort = createdAt: {order: "desc"}
  searchData = {_teamId, _roomId, sort, limit: 20}

  # open from search results
  messageSearchData =
    _teamId: _teamId
    _roomId: _roomId
    _besideId: urlQuery.search

  tagSearchData =
    _teamId: _teamId
    hasTag : true

  deps = [
    dataRely.relyTeamsList()
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
    dataRely.relyTeamInvitaitons(_teamId)
    dataRely.relyLeftContacts(_teamId)
    dataRely.relyGroups(_teamId)
    dataRely.archivedTopics(_teamId)
    dataRely.relyTopicMessages(_teamId, _roomId)
    dataRely.relyIntes(_teamId)
    dataRely.relyTags(_teamId)
    dataRely.relyMessageSearch(messageSearchData) if urlQuery.search?

    # story dep.
    dataRely.stories _teamId

    # notification dep.
    if isTopicJoinded
      dataRely.notifications _teamId, _roomId, 'room'
    else
      dataRely.notifications _teamId
  ]
  info =
    type: 'topic'
    _teamId: _teamId
    _roomId: _roomId
    _channelId: _roomId
    _channelType: 'room'

  deviceActions.networkLoading(info)
  deviceActions.markTeam _teamId
  settingsActions.teamFootprints _teamId
  dataRely.ensure deps, ->
    routerActions.room _teamId, _roomId, urlQuery

    unreadHandlers.simulateRead(triggerEvent = false)

    deviceActions.networkLoaded(info)
    deviceActions.tuned true

    deviceActions.markChannel id: _roomId, type: 'room'

    analytics.countChannelMessages()

    cb?()

exports.chat = (_teamId, _toId, urlQuery={}, cb) ->
  store = recorder.getState()
  settings = query.settings(store)

  _userId = query.userId(store)

  return if _userId is _toId

  _toIds = _creatorIds = [_userId, _toId]
  searchData = {_teamId, _creatorIds, _toIds, isDirectMessage: true, limit: 20}

  # open from search results
  messageSearchData =
    _teamId: _teamId
    _toId: _toId
    _besideId: urlQuery.search

  tagSearchData =
    _teamId: _teamId
    hasTag : true

  deps = [
    dataRely.relyTeamsList()
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
    dataRely.relyTeamInvitaitons(_teamId)
    dataRely.relyLeftContacts(_teamId)
    dataRely.relyGroups(_teamId)
    dataRely.archivedTopics(_teamId)
    dataRely.relyContactMessages(_teamId, _toId)
    dataRely.relyTags(_teamId)
    dataRely.relyMessageSearch(messageSearchData) if urlQuery.search?

    # story dep.
    dataRely.stories _teamId

    # notification dep.
    dataRely.notifications _teamId, _toId, 'dms'
  ]
  info =
    type: 'contact'
    _toId: _toId
    _teamId: _teamId
    _channelId: _toId
    _channelType: 'chat'

  deviceActions.networkLoading(info)
  deviceActions.markTeam _teamId
  settingsActions.teamFootprints _teamId
  dataRely.ensure deps, ->
    routerActions.chat _teamId, _toId, urlQuery

    unreadHandlers.simulateRead(triggerEvent = false)

    settingsActions.unfoldContact _toId, _teamId
    deviceActions.networkLoaded(info)
    deviceActions.tuned true
    deviceActions.markChannel id: _toId, type: 'chat'

    analytics.countChannelMessages()

    cb?()

exports.team = (_teamId, urlQuery={}) ->
  teamDeps = [
    dataRely.relyTeamsList()
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
    dataRely.relyTeamInvitaitons(_teamId)
    dataRely.relyLeftContacts(_teamId)
    dataRely.archivedTopics(_teamId)
    dataRely.relyIntes(_teamId)
    dataRely.relyTags(_teamId)

    dataRely.relyGroups(_teamId)

    # story dep.
    dataRely.stories _teamId

    # notification dep.
    dataRely.notifications _teamId
  ]
  # subscribe updates of current team
  store = recorder.getState()

  teamActions.teamSubscribe _teamId

  info =
    type: 'team'
    _teamId: _teamId
  deviceActions.networkLoading(info)
  deviceActions.markTeam _teamId
  settingsActions.teamFootprints _teamId
  dataRely.ensure teamDeps, ->
    prefsActions.prefsUpdate _latestTeamId: _teamId

    store = recorder.getState()
    notifications = store
    .getIn(['notifications', _teamId])?.filterNot (notification) ->
      notification.get('isMute') or notification.get('isHidden')
    generalRoom = store.getIn(['topics', _teamId]).find (room) -> room.get('isGeneral')
    if notifications?.size > 0
      firstUnreadIndex = notifications.findIndex (n) -> n.get('unreadNum') > 0
      if firstUnreadIndex is -1
        firstUnreadIndex = 0
      notification = notifications.get(firstUnreadIndex)
      type = switch notification.get('type')
        when 'dms' then 'chat'
        when 'room' then 'room'
        when 'story' then 'story'
      _targetId = notification.get('_targetId')
      exports[type] _teamId, _targetId, {}, ->
        deviceActions.networkLoaded(info)
    else if generalRoom?
      exports.room _teamId, generalRoom.get('_id'), {}, ->
        deviceActions.networkLoaded(info)
    else
      deviceActions.networkLoaded(info)
      exports.settingTeams()

    analytics.countChannelMessages()

exports.changeChannel = (_teamId, _roomId, _toId, searchQuery = {}) ->
  if _roomId
    exports.room _teamId, _roomId, searchQuery
  else if _toId
    exports.chat _teamId, _toId, searchQuery
  else
    exports.team _teamId

exports.tags = (_teamId, urlQuery = {}) ->
  store = recorder.getState()
  _userId = query.userId(store)

  searchData =
    _teamId: _teamId
    page: 1
    hasTag: true
    sort: {updatedAt: {order: 'desc'}}
  if urlQuery._roomId?
    searchData._roomId = urlQuery._roomId
  else if urlQuery._toId?
    searchData._toIds = searchData._creatorIds = [urlQuery._toId, _userId]
    searchData.isDirectMessage = true
  if urlQuery._tagId?
    searchData._tagId = urlQuery._tagId

  deps = [
    dataRely.relyTeamsList()
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
    dataRely.relyTeamInvitaitons(_teamId)
    dataRely.relyTags(_teamId)
    dataRely.relyGroups(_teamId)
    dataRely.relyLeftContacts(_teamId)
    dataRely.relyTaggedResults(searchData)

    dataRely.notifications _teamId
  ]

  info =
    type: 'tags'
    _teamId: _teamId
  deviceActions.networkLoading(info)
  dataRely.ensure deps, ->
    routerActions.tags _teamId, urlQuery
    deviceActions.networkLoaded(info)

#
# story router
#
exports.story = (_teamId, _storyId, urlQuery={}, cb) ->
  store = recorder.getState()

  # open from search results
  messageSearchData =
    _teamId: _teamId
    _storyId: _storyId
    _besideId: urlQuery.search

  deps = [
    # team
    dataRely.relyTeamsList()
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
    dataRely.relyTeamInvitaitons(_teamId)

    # contact
    dataRely.contacts _teamId
    dataRely.relyLeftContacts _teamId

    # topics
    dataRely.archivedTopics _teamId

    # message
    dataRely.messages _teamId, _storyId, 'story'
    dataRely.relyMessageSearch(messageSearchData) if urlQuery.search?

    # notification
    dataRely.notifications _teamId, _storyId, 'story'

    # story
    dataRely.story _teamId, _storyId
    dataRely.stories _teamId

    # group
    dataRely.relyGroups _teamId

    #tags
    dataRely.relyTags _teamId
  ]

  info =
    type: 'story'
    _teamId: _teamId
    _storyId: _storyId
    _channelId: _storyId
    _channelType: 'story'

  deviceActions.networkLoading info
  deviceActions.markTeam _teamId
  settingsActions.teamFootprints _teamId

  dataRely.ensure deps, ->
    routerActions.story _teamId, _storyId, urlQuery

    unreadHandlers.simulateRead(triggerEvent = false)

    deviceActions.networkLoaded info
    deviceActions.tuned true
    deviceActions.markChannel id: _storyId, type: 'story'

    analytics.countChannelMessages()

    cb?()

exports.favorites = (_teamId, urlQuery) ->
  store = recorder.getState()
  _userId = query.userId(store)

  searchData =
    _teamId: _teamId
    page: 1
    sort: {favoritedAt: {order: 'desc'}}

  searchData
  deps = [
    # team dep.
    dataRely.relyGroups(_teamId)
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
    dataRely.relyTeamInvitaitons(_teamId)
    dataRely.relyTeamsList()
    dataRely.relyLeftContacts _teamId
    dataRely.relyFavoriteResults searchData

    # story dep.
    dataRely.stories _teamId

    # notification
    dataRely.notifications _teamId
  ]

  info =
    type: 'favorites'
    _teamId: _teamId
  deviceActions.networkLoading info
  dataRely.ensure deps, ->
    routerActions.favorites _teamId, urlQuery
    deviceActions.networkLoaded info

exports.collection = (_teamId, urlQuery) ->
  deps = [
    # team dep.
    dataRely.relyGroups(_teamId)
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
    dataRely.relyTeamInvitaitons(_teamId)
    dataRely.relyTeamsList()
    # common dep.
    dataRely.relyTags _teamId
    dataRely.relyLeftContacts _teamId
    dataRely.notifications _teamId
  ]

  info =
    type: 'search'
    _teamId: _teamId
  deviceActions.networkLoading info
  dataRely.ensure deps, ->
    routerActions.collection _teamId, urlQuery
    deviceActions.networkLoaded info

exports.settingRookie = ->
  routerActions.settingRookie()

exports.settingTeams = ->
  deps = [
    dataRely.relyTeamsList()
  ]

  info =
    type: 'setting-teams'
  deviceActions.networkLoading info
  dataRely.ensure deps, ->
    routerActions.settingTeams()
    deviceActions.networkLoaded info
  analytics.viewTeams()

exports.profile = ->
  deps = [
    dataRely.accounts()
  ]

  info =
    type: 'setting-profile'
  deviceActions.networkLoading info
  dataRely.ensure deps, ->
    routerActions.profile()
    deviceActions.networkLoaded info

exports.teamCreate = ->
  routerActions.teamCreate()

exports.teamSync = ->
  deps = [
    dataRely.accounts()
  ]

  info =
    type: 'setting-sync'
  deviceActions.networkLoading info
  dataRely.ensure deps, ->
    routerActions.teamSync()
    deviceActions.networkLoaded info

exports.teamSyncList = ->
  refer = 'teambition'

  deps = [
    dataRely.accounts()
    dataRely.relyThirdParties(refer)
    dataRely.relyTeamsList()
  ]

  info =
    type: 'setting-sync-team'
  deviceActions.networkLoading info
  dataRely.ensure deps, ->
    routerActions.teamSyncList()
    deviceActions.networkLoaded info

exports.settingHome = ->
  routerActions.settingHome()

exports.back = ->
  if window.history.length > 0
    window.history.back()
  else
    exports.home()

exports.home = (cb) ->
  store = recorder.getState()
  _latestTeamId = store.getIn(['user', 'preference', '_latestTeamId'])
  if _latestTeamId?
    exports.team(_latestTeamId)
  else
    exports.settingTeams()
  cb?()

exports.onPopstate = (info) ->
  _teamId = info.getIn(['data', '_teamId'])
  _roomId = info.getIn(['data', '_roomId'])
  _toId = info.getIn(['data', '_toId'])
  _storyId = info.getIn(['data', '_storyId'])
  urlQuery = info.get('query')?.toJS() or {}
  switch info.get('name')
    when 'home'
      exports.home()
    when 'team'
      exports.team _teamId, urlQuery
    when 'room'
      exports.room _teamId, _roomId, urlQuery
    when 'chat'
      exports.chat _teamId, _toId, urlQuery
    when 'story'
      exports.story _teamId, _storyId, urlQuery
    else
      routerActions.go info.toJS()

exports.goPath = (urlPath) ->
  info = pathUtil.getCurrentInfo routes, urlPath
  exports.onPopstate info

exports.return = ->
  store = recorder.getState()

  if store.hasIn [ 'device', 'lastChannel' ]
    lastChannel = store.getIn [ 'device', 'lastChannel' ]
    if lastChannel?
      _teamId = store.getIn [ 'router', 'data', '_teamId' ]
      _channelId = lastChannel.get 'id'
      switch lastChannel.get 'type'
        when 'chat'
          exports.chat _teamId, _channelId
        when 'room'
          exports.room _teamId, _channelId
        when 'story'
          exports.story _teamId, _channelId
        else
          console.error 'Undifined channel type! please check your markChannel action.'
    else
      console.warn 'Haven\'t mark any channel.'
      exports.home()
  else
    exports.home()

exports.unreadTeam = ->
  store = recorder.getStore()

  currentTeamId = store.getIn ['router', 'data', '_teamId']
  unreadTeam = store.get('teams').find (team) ->
    return false if team.get('_id') is currentTeamId
    return false if (team.get('unread') or 0) is 0
    return true
  if unreadTeam?
    exports.team unreadTeam.get('_id')

exports.create = ->
  store = recorder.getStore()
  currentTeamId = store.getIn ['router', 'data', '_teamId']
  recorder.dispatch 'router/go', name: 'create', data: {_teamId: currentTeamId}, query: {}

exports.integrations = (_teamId, _roomId) ->
  store = recorder.getStore()

  if _roomId?
    queryObject = {_roomId}
  else
    queryObject = {}

  deps = [
    dataRely.relyTeamsList()
    dataRely.relyInteSettings()
    dataRely.relyIntes(_teamId)
  ]

  # strange but async load code first, async load settings second
  require.ensure [], ->
    intePage = require '../app/inte-page'
    lazyModules.define 'inte-page', intePage

    dataRely.ensure deps, ->
      recorder.dispatch 'router/go', name: 'integrations', data: {_teamId}, query: queryObject

    if module.hot
      module.hot.accept '../app/inte-page', ->
        intePage = require '../app/inte-page'
        lazyModules.define 'inte-page', intePage

exports.mentions = (params, searchQuery) ->
  _teamId = params._teamId

  deps = [
    dataRely.relyGroups _teamId
    dataRely.relyTeamTopics _teamId
    dataRely.relyTeamMembers _teamId
    dataRely.relyTeamInvitaitons _teamId
    dataRely.relyTeamsList()
    dataRely.relyLeftContacts _teamId
    dataRely.mentionedMessages params
    dataRely.notifications _teamId
    dataRely.stories _teamId
  ]

  info =
    type: 'mentions'
  deviceActions.markTeam _teamId
  deviceActions.networkLoading info
  dataRely.ensure deps, ->
    routerActions.mentions params, searchQuery
    deviceActions.networkLoaded info

exports.teamOverview = (_teamId) ->
  store = recorder.getStore()

  deps = [
    dataRely.relyTeamsList()
    dataRely.relyTeamActivities _teamId
    dataRely.relyTeamMembers _teamId
    dataRely.relyTeamInvitaitons _teamId
  ]
  dataRely.ensure deps, (resp) ->
    recorder.dispatch 'router/go', name: 'overview', data: {_teamId: _teamId}, query: {}
