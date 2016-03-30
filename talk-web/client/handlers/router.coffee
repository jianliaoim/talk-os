Q = require 'q'
recorder = require 'actions-recorder'
pathUtil = require 'router-view/lib/path'

query = require '../query'
routes = require '../routes'

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

fetchBaseDataIfNeed = ->
  [
    dataRely.relyTeamsList()
  ]

fetchTeamDataIfNeed = (_teamId) ->
  deviceActions.markTeam _teamId
  settingsActions.teamFootprints _teamId
  [
    fetchBaseDataIfNeed()
    dataRely.archivedTopics _teamId
    dataRely.notifications _teamId
    dataRely.stories _teamId
    dataRely.relyGroups _teamId
    dataRely.relyIntes _teamId
    dataRely.relyLeftContacts _teamId
    dataRely.relyTags _teamId
    dataRely.relyTeamInvitaitons _teamId
    dataRely.relyTeamMembers _teamId
    dataRely.relyTeamSubscribe _teamId
    dataRely.relyTeamTopics _teamId
  ]

exports.team = (_teamId, searchQuery = {}) ->
  info =
    type: 'team'
    _teamId: _teamId

  d1 = dataRely.ensure [
    dataRely.notifications _teamId
  ]
  d2 = dataRely.ensure [
    dataRely.relyTeamTopics _teamId
  ]

  if not d1.isSatisfied
    deviceActions.networkLoading(info)
  d1.request()
    .then ->
      deviceActions.markTeam _teamId
      settingsActions.teamFootprints _teamId
      prefsActions.prefsUpdate _latestTeamId: _teamId

      store = recorder.getState()
      notifications = store
      .getIn(['notifications', _teamId])?.filterNot (notification) ->
        notification.get('isMute') or notification.get('isHidden')
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
        Q.reject('skip')
      else
        if not d2.isSatisfied
          deviceActions.networkLoading(info)
        d2.request()
    .then ->
      store = recorder.getState()
      generalRoom = store.getIn(['topics', _teamId]).find (room) -> room.get('isGeneral')
      if generalRoom?
        exports.room _teamId, generalRoom.get('_id'), {}, ->
          deviceActions.networkLoaded(info)
      else
        exports.settingTeams()
        deviceActions.networkLoaded(info)
    .catch (err) ->
      if err isnt 'skip'
        throw new Error(err)
    .done()

fetchRoomDataIfNeed = (_teamId, _roomId, searchQuery = {}) ->
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
    _besideId: searchQuery.search

  tagSearchData =
    _teamId: _teamId
    hasTag : true

  [
    dataRely.relyMessageSearch(messageSearchData) if searchQuery.search?
    dataRely.relyTopicMessages _teamId, _roomId
    if isTopicJoinded
      dataRely.notifications _teamId, _roomId, 'room'
    else
      dataRely.notifications _teamId
  ]

exports.room = (_teamId, _roomId, searchQuery={}, cb) ->
  info =
    type: 'topic'
    _teamId: _teamId
    _roomId: _roomId
    _channelId: _roomId
    _channelType: 'room'

  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchRoomDataIfNeed _teamId, _roomId, searchQuery
  ]
  if not d.isSatisfied
    deviceActions.networkLoading(info)
  d.request()
    .then ->
      analytics.countChannelMessages()
      unreadHandlers.simulateRead(triggerEvent = false)
      deviceActions.tuned true
      deviceActions.markChannel id: _roomId, type: 'room'
      routerActions.room _teamId, _roomId, searchQuery
      deviceActions.networkLoaded(info)
      cb?()
    .done()

fetchChatDataIfNeed = (_teamId, _toId, searchQuery = {}) ->
  store = recorder.getState()
  settings = query.settings(store)

  _userId = query.userId(store)

  return [] if _userId is _toId

  _toIds = _creatorIds = [_userId, _toId]
  searchData = {_teamId, _creatorIds, _toIds, isDirectMessage: true, limit: 20}

  # open from search results
  messageSearchData =
    _teamId: _teamId
    _toId: _toId
    _besideId: searchQuery.search

  tagSearchData =
    _teamId: _teamId
    hasTag : true

  [
    dataRely.relyMessageSearch(messageSearchData) if searchQuery.search?
    dataRely.relyContactMessages _teamId, _toId
    dataRely.notifications _teamId, _toId, 'dms'
  ]

exports.chat = (_teamId, _toId, searchQuery = {}, cb) ->
  info =
    type: 'contact'
    _toId: _toId
    _teamId: _teamId
    _channelId: _toId
    _channelType: 'chat'

  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchChatDataIfNeed _teamId, _toId, searchQuery
  ]
  if not d.isSatisfied
    deviceActions.networkLoading(info)
  d.request()
    .then ->
      routerActions.chat _teamId, _toId, searchQuery
      unreadHandlers.simulateRead(triggerEvent = false)
      deviceActions.tuned true
      deviceActions.markChannel id: _toId, type: 'chat'
      analytics.countChannelMessages()
      deviceActions.networkLoaded(info)
      cb?()
    .done()

exports.changeChannel = (_teamId, _roomId, _toId, searchQuery = {}) ->
  if _roomId
    exports.room _teamId, _roomId, searchQuery
  else if _toId
    exports.chat _teamId, _toId, searchQuery
  else
    exports.team _teamId

fetchTagsDataIfNeed = (_teamId, searchQuery = {}) ->
  store = recorder.getState()
  _userId = query.userId(store)

  searchData =
    _teamId: _teamId
    page: 1
    hasTag: true
    sort: {updatedAt: {order: 'desc'}}

  if searchQuery._roomId?
    searchData._roomId = searchQuery._roomId
  else if searchQuery._toId?
    searchData._toIds = searchData._creatorIds = [searchQuery._toId, _userId]
    searchData.isDirectMessage = true
  if searchQuery._tagId?
    searchData._tagId = searchQuery._tagId

  [
    dataRely.relyTaggedResults(searchData)
  ]

exports.tags = (_teamId, searchQuery = {}) ->
  info =
    type: 'tags'
    _teamId: _teamId

  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchTagsDataIfNeed _teamId, searchQuery
  ]
  if not d.isSatisfied
    deviceActions.networkLoading(info)
  d.request()
    .then ->
      routerActions.tags _teamId, searchQuery
      deviceActions.networkLoaded(info)
    .done()

#
# story router
#

fetchStoryDataIfNeed = (_teamId, _storyId, searchQuery = {}) ->
  messageSearchData =
    _teamId: _teamId
    _storyId: _storyId
    _besideId: searchQuery.search

  [
    dataRely.story _teamId, _storyId
    dataRely.messages _teamId, _storyId, 'story'
    dataRely.relyMessageSearch(messageSearchData) if searchQuery.search?
    dataRely.notifications _teamId, _storyId, 'story'
  ]

exports.story = (_teamId, _storyId, searchQuery = {}, cb) ->
  info =
    type: 'story'
    _teamId: _teamId
    _storyId: _storyId
    _channelId: _storyId
    _channelType: 'story'

  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchStoryDataIfNeed _teamId, _storyId
  ]
  if not d.isSatisfied
    deviceActions.networkLoading(info)
  d.request()
    .then ->
      routerActions.story _teamId, _storyId, searchQuery
      unreadHandlers.simulateRead(triggerEvent = false)
      deviceActions.tuned true
      deviceActions.markChannel id: _storyId, type: 'story'
      analytics.countChannelMessages()
      deviceActions.networkLoaded(info)
      cb?()
    .done()


fetchFavoritesDataIfNeed = (_teamId) ->
  searchData =
    _teamId: _teamId
    page: 1
    sort: {favoritedAt: {order: 'desc'}}

  [
    dataRely.relyFavoriteResults searchData
  ]

exports.favorites = (_teamId, searchQuery) ->
  info =
    type: 'favorites'
    _teamId: _teamId

  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchFavoritesDataIfNeed _teamId
  ]
  if not d.isSatisfied
    deviceActions.networkLoading(info)
  d.request()
    .then ->
      routerActions.favorites _teamId, searchQuery
      deviceActions.networkLoaded(info)
    .done()

fetchCollectionDataIfNeed = ->
  []

exports.collection = (_teamId, searchQuery = {}) ->
  info =
    type: 'search'
    _teamId: _teamId

  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchCollectionDataIfNeed()
  ]
  if not d.isSatisfied
    deviceActions.networkLoading(info)
  d.request()
    .then ->
      routerActions.collection _teamId, searchQuery
      deviceActions.networkLoaded(info)
    .done()

exports.settingRookie = ->
  routerActions.settingRookie()

exports.settingTeams = ->
  d = dataRely.ensure [
    dataRely.relyTeamsList()
  ]
  d.request()
    .then ->
      routerActions.settingTeams()
      analytics.viewTeams()
    .done()

exports.profile = ->
  d = dataRely.ensure [
    dataRely.accounts()
  ]
  d.request()
    .then ->
      routerActions.profile()
    .done()

exports.teamCreate = ->
  routerActions.teamCreate()

exports.teamSync = ->
  d = dataRely.ensure [
    dataRely.accounts()
  ]
  d.request()
    .then ->
      routerActions.teamSync()
    .done()

exports.teamSyncList = ->
  refer = 'teambition'

  d = dataRely.ensure [
    dataRely.accounts()
    dataRely.relyThirdParties(refer)
    dataRely.relyTeamsList()
  ]
  d.request()
    .then ->
      routerActions.teamSyncList()
    .done()

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

fetchCreateDataIfNeed = (_teamId) ->
  []

exports.create = (_teamId, searchQuery = {}) ->
  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchCreateDataIfNeed()
  ]
  d.request()
    .then ->
      routerActions.create _teamId, searchQuery
    .done()

fetchIntegrationsDataIfNeed = (_teamId) ->
  [
    dataRely.relyInteSettings()
    dataRely.relyIntes _teamId
  ]

exports.integrations = (_teamId, _roomId, searchQuery = {}) ->
  # strange but async load code first, async load settings second
  require.ensure [], ->
    intePage = require '../app/inte-page'
    lazyModules.define 'inte-page', intePage

    d = dataRely.ensure [
      fetchTeamDataIfNeed _teamId
      fetchIntegrationsDataIfNeed _teamId
    ]
    d.request()
      .then ->
        queryObject =
          if _roomId? or searchQuery._roomId
            _roomId: _roomId or searchQuery._roomId
          else
            {}

        routerActions.integrations(_teamId, searchQuery)
      .done()

    if module.hot
      module.hot.accept '../app/inte-page', ->
        intePage = require '../app/inte-page'
        lazyModules.define 'inte-page', intePage

fetchMentionsDataIfNeed = (params) ->
  [
    dataRely.mentionedMessages params
  ]

exports.mentions = (params, searchQuery = {}) ->
  d = dataRely.ensure [
    fetchTeamDataIfNeed params._teamId
    fetchMentionsDataIfNeed params
  ]
  d.request()
    .then ->
      routerActions.mentions params, searchQuery
    .done()

fetchTeamOverviewDataIfNeed = (_teamId) ->
  [
    dataRely.relyTeamActivities _teamId
  ]

exports.teamOverview = (_teamId) ->
  d = dataRely.ensure [
    fetchTeamDataIfNeed _teamId
    fetchTeamOverviewDataIfNeed _teamId
  ]
  d.request()
    .then ->
      routerActions.overview(_teamId)
    .done()
