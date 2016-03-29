
recorder = require 'actions-recorder'
pathUtil = require 'router-view/lib/path'

routes = require '../guest/routes'
dispatcher = require '../dispatcher'
socket = require '../network/socket'

time = require '../util/time'

userActions = require '../actions/user'
guestActions  = require './actions'
routerActions = require '../actions/router'
deviceActions = require '../actions/device'

loopStarted = false
loopState = ->
  return if loopStarted
  loopStarted = true
  sendState()
  time.every (10 ** 5), sendState

sendState = ->
  if recorder.getState().get('user')?
    _teamId = recorder.getState().getIn(['device', '_teamId'])
    userActions.state _teamId

joinRoom = ->
  guestToken = location.pathname.replace('/rooms/', '')
  guestActions.roomJoin guestToken,
    (resp) ->
      socket.connect()
      deviceActions.markTeam resp._teamId
      loopState()
      routerActions.guestRoom resp._id
    (error) ->
      routerActions.guestDisabled()

fetchTopicData = (guestToken) ->
  guestActions.roomReadOne guestToken,
    (resp) ->
      fetchUserData()
    (resp) ->
      routerActions.guestDisabled()

fetchUserData = ->
  userActions.userMe \
    (resp) ->
      joinRoom()
    , (resp) ->
      routerActions.guestSignup()

exports.initialize = ->
  oldAddress = "#{location.pathname}#{location.search}"
  defaultRouteInfo = pathUtil.getCurrentInfo routes, oldAddress
  switch defaultRouteInfo.get('name')
    when 'room'
      guestToken = defaultRouteInfo.getIn(['data', 'token'])
      fetchTopicData(guestToken)
    else
      routerActions.guest404()

exports.registerUser = (user) ->
  dispatcher.handleViewAction type: 'user/me', data: user

exports.joinTopic = ->
  joinRoom()
