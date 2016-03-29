React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'

routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

orders = require '../util/orders'
analytics = require '../util/analytics'

TeamName = React.createFactory require './team-name'

{ hr, div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-menu'
  mixins: [PureRenderMixin]

  propTypes:
    teams: T.instanceOf(Immutable.List).isRequired
    onInteClick: T.func.isRequired
    onQRCodeClick: T.func.isRequired
    onPopoverClose: T.func.isRequired
    onDetailsClick: T.func.isRequired

  onTeamDetailsClick: ->
    @props.onDetailsClick()
    @onPopoverClose()

  onIntegrationsClick: ->
    @props.onInteClick()
    @onPopoverClose()

  onQRCodeClick: ->
    @props.onQRCodeClick()
    @onPopoverClose()

  onTeamSwitchClick: ->
    # add timeout, or bubbled event tries to access removed DOM
    routerHandlers.settingTeams()

  onPopoverClose: ->
    @props.onPopoverClose()

  renderTeams: ->
    footprints = query.teamFootprints(recorder.getState())
    n = 0
    @props.teams
    .sort orders.byPopularTeam(footprints)
    .sortBy (team) -> -1 * team.get('unread')
    .takeWhile (team) ->
      unread = team.get('unread')
      if unread > 0
        true
      else
        n += 1
        n <= 3
    .map (team) =>
      onClick = =>
        @onPopoverClose()
        routerHandlers.team team.get('_id')
        analytics.chooseTeam()
        analytics.enterTeam()
      TeamName
        key: team.get('_id'), data: team, onClick: onClick
        showSource: false, large: false

  render: ->
    div className: 'team-menu',
      div className: 'item line', onClick: @onTeamDetailsClick,
        span className: 'icon icon-td-pencil2'
        lang.getText 'team-settings'
      div className: 'item line', onClick: @onIntegrationsClick,
        span className: 'icon icon-config'
        lang.getText 'integrations'
      div className: 'item line', onClick: @onQRCodeClick,
        span className: 'icon icon-qrcode'
        lang.getText 'team-qrcode'
      hr className: 'divider-thin'
      div className: 'embed',
        @renderTeams()
      div className: 'item line', onClick: @onTeamSwitchClick,
        span className: 'icon icon-more'
        lang.getText 'switch-teams'
