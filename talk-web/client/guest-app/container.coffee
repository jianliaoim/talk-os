React = require 'react'
keycode = require 'keycode'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

Devtools = React.createFactory require 'actions-recorder/lib/devtools'
Disabled = React.createFactory require './disabled'
AppSignup   = React.createFactory require './signup'
TopicPage   = React.createFactory require './topic-page'
AppMissing  = React.createFactory require './missing'
NotifyCenter = React.createFactory require '../app/notify-center'
ContainerWireframe = React.createFactory require '../app/container-wireframe'

div = React.createFactory 'div'
loadingSentences = require '../util/loading-sentences'

module.exports = React.createClass
  displayName: 'app-container'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired
    core: React.PropTypes.object.isRequired

  getInitialState: ->
    showDevtools: false
    path: Immutable.List()

  componentDidMount: ->
    window.addEventListener 'resize', @onWindowResize
    window.addEventListener 'keydown', @onWindowKeydown

  componentWillUnmount: ->
    window.removeEventListener 'resize', @onWindowResize
    window.removeEventListener 'keydown', @onWindowKeydown

  onPathChange: (path) ->
    @setState path: path

  onWindowResize: ->
    @forceUpdate()

  onWindowKeydown: (event) ->
    if (event.metaKey or event.ctrlKey) and event.shiftKey and keycode(event.keyCode) is 'a'
      @setState showDevtools: not @state.showDevtools
      event.preventDefault()

  onSignup: (user) ->
    @setState user: user
    @joinRoom()

  renderDevtools: ->
    div className: 'devtools-layer',
      Devtools
        core: @props.core
        language: 'zh'
        width: window.innerWidth
        height: window.innerHeight
        path: @state.path
        onPathChange: @onPathChange

  render: ->
    router = @props.store.get('router')
    _teamId = @props.store.getIn(['device', '_teamId'])
    _roomId = router.getIn(['data', '_roomId'])
    topics = @props.store.get('topics')

    div className: 'app-container',
      switch router.get('name')
        when 'home'
          ContainerWireframe
            sentence: loadingSentences.get(new Date())
        when 'room'
          TopicPage router: router, _teamId: _teamId, _roomId: _roomId
        when 'disabled'
          Disabled()
        when 'signup'
          AppSignup onSignup: @onSignup, topics: topics
        when '404'
          AppMissing()
        else
          AppMissing()
      NotifyCenter router: router
      if @state.showDevtools
        @renderDevtools()
