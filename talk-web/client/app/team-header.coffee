cx = require 'classnames'
React = require 'react'
query = require '../query'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

handlers = require '../handlers'

lang = require '../locales/lang'

accountActions = require '../actions/account'

url = require '../util/url'
time = require '../util/time'
keyboard  = require '../util/keyboard'
analytics = require '../util/analytics'

TeamMenu = React.createFactory require './team-menu'
TeamQRCode = React.createFactory require './team-qrcode'
TeamDetails = React.createFactory require './team-details'

Icon = React.createFactory require '../module/icon'
UnreadBadge = React.createFactory require '../module/unread-badge'

LightModalBeta = React.createFactory require '../module/light-modal'
LightPopver = React.createFactory require '../module/light-popover'

{ a, i, div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-header'
  mixins: [ PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    team: T.instanceOf(Immutable.Map).isRequired
    teams: T.instanceOf(Immutable.Map).isRequired
    router: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showMenu: false
    showDetails: false
    showQRCode: false

  componentDidMount: ->
    @_menuEl = @refs.menu

  getException: ->
    @props.teams.toList().filter (team) =>
      team.get('_id') isnt @props._teamId

  getUnread: ->
    @getException().reduce (unread, team) ->
      unread + team.get 'unread'
    , 0

  getMenuArea: ->
    @_menuEl?.getBoundingClientRect() or {}

  getMenuPosition: (area) ->
    top: area.bottom + 10
    left: area.left

  onDetailsShow: ->
    @setState
      showDetails: true

  onCloseMenu: ->
    @setState
      showMenu: false

  onToggleMenu: (event) ->
    event.stopPropagation()
    @setState
      showMenu: not @state.showMenu

  onPopoverClose: -> @setState showMenu: false

  onInteClick: ->
    accountActions.fetch()
    handlers.router.integrations @props.team.get('_id')
    analytics.openIntegrationFromTeam()

  onDetailsClick: ->
    @setState showDetails: true

  onDetailsClose: ->
    @setState showDetails: false

  onQRCodeClick: ->
    @setState
      showQRCode: true

  onQRCodeClose: ->
    @setState
      showQRCode: false

  renderDetails: ->
    LightModalBeta
      name: 'team-details'
      show: @state.showDetails
      title: lang.getText('team-settings')
      onCloseClick: @onDetailsClose
      TeamDetails
        _teamId: @props._teamId
        router: @props.router
        onClose: @onDetailsClose

  renderQRCode: ->
    LightModalBeta
      name: 'team-qrcode'
      show: @state.showQRCode
      title: lang.getText 'team-qrcode'
      onCloseClick: @onQRCodeClose
      TeamQRCode
        team: query.teamBy recorder.getState(), @props._teamId

  renderMenu: ->
    LightPopver
      show: @state.showMenu
      title: lang.getText('team-menu')
      baseArea: if @state.showMenu then @getMenuArea() else {}
      showClose: true
      onPopoverClose: @onCloseMenu
      positionAlgorithm: @getMenuPosition
      TeamMenu
        teams: @getException()
        onInteClick: @onInteClick
        onQRCodeClick: @onQRCodeClick
        onDetailsClick: @onDetailsShow
        onPopoverClose: @onCloseMenu

  render: ->
    div className: 'team-header flex-static',
      div className: 'wrapper flex-horiz flex-static flex-vcenter',
        a ref: 'menu', className: cx('toggle-menu', 'active': @state.showMenu), onClick: @onToggleMenu,
          Icon name: 'menu', size: 22
          UnreadBadge round: true, number: @getUnread(), showNumber: false, size: 8
        span className: 'flex-fill text-overflow', @props.team.get 'name'
      @renderDetails()
      @renderMenu()
      @renderQRCode()
