recorder = require 'actions-recorder'

api = require '../network/api'

actions = require '../actions/index'
userActions = require '../actions/user'
teamActions = require '../actions/team'
roomActions = require '../actions/room'
storyActions = require '../actions/story'
messageActions = require '../actions/message'
notificationActions = require '../actions/notification'
accountActions = require '../actions/account'

exports.newConnection = ->
  api.users.subscribe.post()

exports.longReconnection = (cb) ->
  # 这个断线有个问题：
  # 当我们在其他没有 _teamId 的页面， 比如 /settings 页面
  # 这里断线重连就会挂掉
  store = recorder.getState()

  _teamId = store.getIn ['router', 'data', '_teamId']
  _roomId = store.getIn ['router', 'data', '_roomId']
  _toId = store.getIn ['router', 'data', '_toId']
  _storyId = store.getIn ['router', 'data', '_storyId']

  fetchUser = -> userActions.userMe()
  fetchTeams = -> teamActions.teamsFetch()
  fetchTeamMembers = -> teamActions.teamMembers(_teamId)
  fetchTopics = -> teamActions.teamTopics(_teamId)
  fetchAccounts = -> accountActions.fetch()
  fetchInteSettings = -> actions.inte.getSettings()
  fetchNotifications = -> notificationActions.read(_teamId, {})

  if _teamId?
    subscribeTeam = -> teamActions.teamSubscribe(_teamId)
    if _roomId?
      fetchChannel = -> roomActions.fetch(_roomId)
    else if _toId?
      fetchChannel = -> messageActions.messageReadChat(_teamId, _toId)
    else if _storyId?
      fetchChannel = -> storyActions.read(_teamId, {})

    calls = [
      subscribeTeam, fetchUser, fetchAccounts, fetchTeams
      fetchTeamMembers, fetchTopics, fetchChannel, fetchNotifications, fetchInteSettings
    ]
  else
    calls = [fetchUser, fetchAccounts, fetchTeams, fetchInteSettings]

  # TODO: 这里需要报错处理
  calls.forEach (fn) ->
    fn()
