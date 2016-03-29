React = require 'react'
keycode = require 'keycode'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
routes = require '../routes'

deviceActions = require '../actions/device'

routerHandlers = require '../handlers/router'

lang = require '../locales/lang'
lazyModules = require '../util/lazy-modules'
loadingSentences = require '../util/loading-sentences'

Devtools = React.createFactory require 'actions-recorder/lib/devtools'
Addressbar = React.createFactory require 'router-view'

AppTitle = React.createFactory require './title'
TeamPage = React.createFactory require './team-page'
ProfilePage = React.createFactory require './profile-page'
SettingPage = React.createFactory require './setting-page'
NotifyCenter = React.createFactory require './notify-center'
TeamOverview = React.createFactory require './team-overview'
TeamWireframe = React.createFactory require './team-wireframe'
LaunchFullscreen = React.createFactory require './launch-fullscreen'
ContainerWireframe = React.createFactory require './container-wireframe'
NotFound = React.createFactory require './not-found'

div = React.createFactory 'div'

# mounted to router
module.exports = React.createClass
  displayName: 'app-container'

  propTypes:
    core: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showDebugger: false
    path: Immutable.List()

  componentDidMount: ->
    window.addEventListener 'keydown', @onWindowKeydown
    window.addEventListener 'focus', @onWindowFocus
    window.addEventListener 'blur', @onWindowBlur

  componentWillUnmount: ->
    window.removeEventListener 'keydown', @onWindowKeydown
    window.removeEventListener 'focus', @onWindowFocus
    window.removeEventListener 'blur', @onWindowBlur

  dataFilter: (store) ->
    store

  onWindowKeydown: (event) ->
    if (event.metaKey or event.ctrlKey) and event.shiftKey and keycode(event.keyCode) is 'a'
      @setState showDebugger: not @state.showDebugger
      event.preventDefault()

  onWindowFocus: (event) ->
    deviceActions.detectFocus true

  onWindowBlur: (event) ->
    deviceActions.detectFocus false

  onPopstate: (info) ->
    routerHandlers.onPopstate info

  onPathChange: (path) ->
    @setState path: path

  renderAddressbar: ->
    store = @props.core.get 'store'

    loadingStack = store.getIn(['device', 'loadingStack'])
    Addressbar
      route: store.get('router')
      rules: routes
      onPopstate: @onPopstate
      inHash: false
      skipRendering: loadingStack.size > 0

  renderPage: ->
    store = @props.core.get 'store'
    router = store.get('router')
    _teamId = router.getIn(['data', '_teamId'])
    _userId = store.getIn(['user', '_id'])

    switch router.get('name')
      when 'chat', 'collection', 'favorites', 'launch', 'room', 'story', 'tags', 'team', 'team404', 'mentions'
        TeamPage
          store: store
          device: store.get 'device'
          router: store.get 'router'
      when 'setting-page', 'setting-rookie', 'setting-sync', 'setting-sync-teams', 'setting-team-create', 'setting-teams'
        SettingPage
          router: store.get 'router'
      when 'profile'
        ProfilePage()
      when 'create'
        LaunchFullscreen _teamId: _teamId, _userId: _userId
      when 'integrations'
        IntePage = React.createFactory lazyModules.load('inte-page')
        IntePage _teamId: _teamId, _roomId: router.getIn(['query', '_roomId']), settings: store.get('inteSettings')
      when 'home'
        ContainerWireframe
          sentence: loadingSentences.get(new Date())
      when 'overview'
        team = store.getIn ['teams', _teamId]
        contacts = store.getIn ['contacts', _teamId]
        userInContact = contacts.find (contact) ->
          contact.get('_id') is _userId
        isAdmin = userInContact?.get('role') in ['owner', 'admin']
        activities = store.getIn ['activities', _teamId]
        invitations = store.getIn ['invitations', _teamId]
        TeamOverview
          team: team, activities: activities, contacts: contacts, router: store.get('router')
          user: store.get('user')
          teams: store.get('teams')
          invitations: invitations
          isAdmin: isAdmin
      when '404'
        NotFound()
      else
        NotFound()

  renderLoadingOrPage: ->
    store = @props.core.get 'store'
    user = store.get('user')
    loadingStack = store.getIn(['device', 'loadingStack'])
    if (not user?)
      ContainerWireframe
        sentence: loadingSentences.get(new Date())
    else if loadingStack.size > 0
      switch loadingStack.first().get('type')
        when 'team'
          TeamWireframe
            team: query.teamBy store, loadingStack.first().get('_teamId')
        else @renderPage()
    else @renderPage()

  render: ->
    store = @props.core.get 'store'

    div className: 'app-container',
      NotifyCenter router: store.get('router')
      AppTitle()
      @renderAddressbar()
      @renderLoadingOrPage()
      if @state.showDebugger
        div className: 'devtools-layer',
          Devtools
            core: @props.core
            language: 'zh'
            width: window.innerWidth
            height: window.innerHeight
            path: @state.path
            onPathChange: @onPathChange
