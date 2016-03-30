cx = require 'classnames'
React = require 'react'
query = require '../query'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

handlers = require '../handlers'
analytics = require '../util/analytics'
handlerRouter = require '../handlers/router'

lang = require '../locales/lang'

mixinRouter = require '../mixin/router'
mixinSubscribe = require '../mixin/subscribe'
settingsActions = require '../actions/settings'

Tooltip = React.createFactory require '../module/tooltip'
TeamTools = React.createFactory require './team-tools'
UserCorner = React.createFactory require './user-corner'
Icon = React.createFactory require '../module/icon'

LaunchButton = React.createFactory require '../module/launch-button'

{ div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'TeamToolbar'

  mixins: [ mixinRouter, mixinSubscribe, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    user: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    drawerStatus: @getDrawerStatus()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState drawerStatus: @getDrawerStatus()

  getDrawerStatus: ->
    query.drawerStatus(recorder.getState())

  onRoute: ->
    if @isActiveRoute 'launch'
      handlerRouter.return()
    else
      handlerRouter.launch @props._teamId

  onOpen: (event) ->
    event.stopPropagation()
    handlers.router.create(@props._teamId)
    analytics.startTalk()

  toggleTeamDirectory: (event) ->
    event.stopPropagation()
    if @state.drawerStatus is 'member'
      settingsActions.closeDrawer()
    else
      settingsActions.openDrawer 'member'

  renderDivider: ->
    div className: 'button-divider'

  render: ->
    cxMember = cx 'member', 'active': @state.drawerStatus is 'member'
    div className: 'team-toolbar flex-between flex-horiz flex-vcenter flex-static',
      LaunchButton
        active: @isActiveRoute 'launch'
        onClick: @onOpen
      div className: 'flex-horiz flex-vcenter flex-static',
        Tooltip template: lang.getText('contacts'),
          Icon name: 'roster', size: 18, onClick: @toggleTeamDirectory, className: cxMember
        @renderDivider()
        TeamTools
          _teamId: @props._teamId
          router: @props.router
        @renderDivider()
        UserCorner
          _teamId: @props._teamId
          user: @props.user
