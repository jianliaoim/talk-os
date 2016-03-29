
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

schedule = require '../util/schedule'

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

  fetchUser = (success, fail) -> userActions.userMe(success, fail)
  fetchTeams = (success, fail) -> teamActions.teamsFetch(success, fail)
  fetchTeamMembers = (success, fail) -> teamActions.teamMembers(_teamId, success, fail)
  fetchTopics = (success, fail) -> teamActions.teamTopics(_teamId, success, fail)
  fetchAccounts = (success, fail) -> accountActions.fetch(success, fail)
  fetchInteSettings = (success, fail) -> actions.inte.getSettings(success, fail)
  fetchNotifications = (success, fail) -> notificationActions.read(_teamId, {}, success, fail)

  if _teamId?
    subscribeTeam = (success, fail) -> teamActions.teamSubscribe(_teamId, success, fail)
    if _roomId?
      fetchChannel = (success, fail) -> roomActions.fetch(_roomId, success, fail)
    else if _toId?
      fetchChannel = (success, fail) -> messageActions.messageReadChat(_teamId, _toId, success, fail)
    else if _storyId?
      fetchChannel = (success, fail) -> storyActions.read(_teamId, {}, success, fail)

    calls = [
      subscribeTeam, fetchUser, fetchAccounts, fetchTeams
      fetchTeamMembers, fetchTopics, fetchChannel, fetchNotifications, fetchInteSettings
    ]
  else
    calls = [fetchUser, fetchAccounts, fetchTeams, fetchInteSettings]

  schedule.all calls, (results) ->
    cb? results
