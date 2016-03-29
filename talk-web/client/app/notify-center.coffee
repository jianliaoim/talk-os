React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
config = require '../config'

eventBus = require '../event-bus'
socket = require '../network/socket'

notifyActions = require '../actions/notify'
prefsActions = require '../actions/prefs'
userActions = require '../actions/user'
routerHandlers = require '../handlers/router'

mixinSubscribe = require '../mixin/subscribe'

assemble = require '../util/assemble'
detect = require '../util/detect'
notify = require '../util/notify'
time = require '../util/time'
lookup = require '../util/lookup'

NotifyUpgrade = React.createFactory require '../app/notify-upgrade'
Transition = require '../module/transition'

div = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'notify-center'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    router: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    messages: @getMessages()
    needUpgrade: false
    noAutoUpgrade: false
    prefs: @getPrefs()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        messages: @getMessages()
        prefs: @getPrefs()

    # TODO, better to put in global schema ['device', 'needUpdate']
    @loopState()

    socket.on 'message:create', @onMessageCreate
    @detectNotification()

  componentWillUnmount: ->
    socket.off 'message:create', @onMessageCreate

  getMessages: ->
    query.notices(recorder.getState())

  getPrefs: ->
    query.prefs(recorder.getState()) or Immutable.Map()

  detectNotification: ->
    if @state.prefs.get('desktopNotification')
      window.Notification?.requestPermission (permission) ->
        if permission is 'denied'
          prefsActions.prefsUpdate desktopNotification: false

  loopState: ->
    _teamId = @props.router.getIn(['data', '_teamId'])
    if window.navigator.onLine and _teamId
      userActions.state _teamId, (state) =>
        if @_version? and state.version isnt @_version
          @setState needUpgrade: true
        @_version = state.version

    time.delay (10 ** 5), @loopState

  focus: ->
    window.focus()
    eventBus.emit 'dirty/force-read'

  onMessageCreate: (data) ->
    return if not @state.prefs.get('desktopNotification')
    return if detect.isPageFocused()
    return if data.isSystem

    _teamId = data._teamId
    _channelId = lookup.getMessageChannelId(Immutable.fromJS(data))
    return if data.notification?.isMute

    if data._teamId is @props.router.getIn(['data', '_teamId'])
      teamName = undefined
    else
      team = query.teamBy(recorder.getState(), data._teamId)
      if team?
        teamName = team.get('name')
    _userId = query.userId(recorder.getState())
    return if data._creatorId is _userId
    if data._roomId?
      if @state.prefs.get('notifyOnRelated')
        return unless detect.userInContent data.body, _userId
      content = assemble.notification data, teamName
      notify.desktop content, =>
        @focus()
        return if config.isGuest
        routerHandlers.room data._teamId, data._roomId
    else if data._storyId?
      if @state.prefs.get('notifyOnRelated')
        return unless detect.userInContent data.body, _userId
      content = assemble.notification data, teamName
      notify.desktop content, =>
        @focus()
        return if config.isGuest
        routerHandlers.story data._teamId, data._storyId
    else if data._toId?
      return if data._creatorId is _userId
      content = assemble.notification data, teamName
      notify.desktop content, =>
        @focus()
        return if config.isGuest
        routerHandlers.chat data._teamId, data._creatorId

  onRemove: (data) ->
    notifyActions.remove data._id

  onDismissUpgrade: ->
    @setState noAutoUpgrade: true

  renderItem: (data) ->
    iconClass =
      switch data.get('type')
        when 'success'  then 'icon icon-state-check'
        when 'error'    then 'icon icon-circle-remove'
        when 'info'     then 'icon icon-circle-info'
        when 'warn'     then 'icon icon-circle-warning2'
        else 'icon'

    onRemove = => @onRemove(data)

    div className: "item is-#{data.get('type')}", key: data.get('_id'),
      span className: iconClass
      span className: 'content', data.get('text')
      if data.getIn(['config', 'isSticky'])
        span className: 'icon icon-remove', onClick: onRemove

  render: ->

    div className: 'notify-center',
      # disabled animtion temporarily due to the bugs
      # https://github.com/facebook/react/issues/1326
      React.createElement Transition, className: 'notify-container', transitionName: 'fade', enterTimeout: 200, leaveTimeout: 350,
        @state.messages.map @renderItem
      React.createElement Transition, transitionName: 'fade', enterTimeout: 200, leaveTimeout: 350,
        if @state.needUpgrade and (not @state.noAutoUpgrade)
          NotifyUpgrade onDismiss: @onDismissUpgrade
