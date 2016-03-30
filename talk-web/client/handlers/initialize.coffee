recorder = require 'actions-recorder'

config = require '../config'
lang = require '../locales/lang'
query = require '../query'
socket = require '../network/socket'
handlers = require '../handlers'
analytics = require '../util/analytics'

teamActions = require '../actions/team'
userActions = require '../actions/user'
storyActions = require '../actions/story'
notifyActions = require '../actions/notify'

routerHandlers = require '../handlers/router'

socket = require '../network/socket'

# loading solutions

getId = (team) -> team._id
loadTeam = (_teamId, _roomId, searchQuery) ->
  teamActions.teamsFetch (resp) ->
    if resp.length is 0
      routerHandlers.settingTeams()
    else
      if _teamId? and (_teamId in resp.map(getId))
        teamActions.teamTopics _teamId, (teamData) ->
          targetRoom = query.topicsByOne recorder.getState(), _teamId, _roomId
          if targetRoom?
            routerHandlers.room _teamId, targetRoom.get('_id'), searchQuery
          else
            generalRoom = query.topicsByOne recorder.getState(), _teamId
            routerHandlers.room _teamId, generalRoom.get('_id')
          analytics.enterTeam()
      else
        routerHandlers.settingTeams()

loadChat = (_teamId, _toId, searchQuery) ->
  routerHandlers.chat _teamId, _toId, searchQuery

loadStory = (_teamId, _storyId, searchQuery) ->
  storyActions.readone _storyId
  , ->
    routerHandlers.story _teamId, _storyId, searchQuery
  , ->
    routerHandlers.home()

exports.loadPage = loadPage = (preference, defaultRouteInfo) ->
  _toId = defaultRouteInfo.getIn(['data', '_toId'])
  _roomId = defaultRouteInfo.getIn(['data', '_roomId'])
  _teamId = defaultRouteInfo.getIn(['data', '_teamId']) or preference._latestTeamId
  _storyId = defaultRouteInfo.getIn(['data', '_storyId'])
  searchQuery = defaultRouteInfo.get('query').toJS()

  switch defaultRouteInfo.get('name')
    # root handler
    when 'home', 'team', 'team404', '404'
      loadTeam _teamId, _roomId, searchQuery

    # channel handler
    when 'chat'
      loadChat _teamId, _toId, searchQuery
    when 'collection'
      routerHandlers.collection _teamId, searchQuery
    when 'favorites'
      routerHandlers.favorites _teamId, searchQuery
    when 'room'
      routerHandlers.room _teamId, _roomId, searchQuery
    when 'story'
      loadStory _teamId, _storyId, searchQuery
    when 'tags'
      routerHandlers.tags _teamId, searchQuery
    when 'create'
      routerHandlers.create _teamId, searchQuery

    when 'overview'
      handlers.router.teamOverview _teamId

    when 'mentions'
      routerHandlers.mentions { _teamId }, searchQuery

    when 'integrations'
      routerHandlers.integrations _teamId, _roomId, searchQuery

    # profile handler
    when 'profile'
      routerHandlers.profile()

    # setting handler
    when 'setting-page'
      routerHandlers.settingHome()
    when 'setting-rookie'
      routerHandlers.settingRookie()
    when 'setting-sync'
      routerHandlers.teamSync()
    when 'setting-sync-teams'
      routerHandlers.teamSyncList()
    when 'setting-team-create'
      routerHandlers.teamCreate()
    when 'setting-teams'
      routerHandlers.settingTeams()
    else
      routerHandlers.settingTeams()

# steps entry

exports.start = (defaultRouteInfo, cb) ->

  userActions.userMe \
    (resp) ->
      socket.connect ->
        loadPage(resp.preference, defaultRouteInfo)
        cb() # using callback due to a popstate bug in safari
  , (error) ->
    cb()
