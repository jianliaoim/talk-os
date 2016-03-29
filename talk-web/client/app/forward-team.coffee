React = require 'react'
cx    = require 'classnames'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
query = require '../query'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'
recorder = require 'actions-recorder'

handlers = require '../handlers'
orders = require '../util/orders'

SearchList = React.createFactory require './search-list'
TeamName = React.createFactory require './team-name'
LiteLoadingCircle = React.createFactory require('react-lite-misc').LoadingCircle

{ div, span, input } = React.DOM

T  = React.PropTypes
l  = lang.getText

module.exports = React.createClass
  displayName: 'forward-menu'
  mixins: [ mixinQuery, mixinSubscribe, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    onTeamSwitch: T.func.isRequired

  getInitialState: ->
    teams: @getTeams()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState teams: @getTeams()

  onTeamSwitch: (_teamId) ->
    @setState selectedId: _teamId
    handlers.team.channels _teamId, =>
      @props.onTeamSwitch _teamId

  renderTeamList: ->
    div className: 'list thin-scroll flex-vert',
      @state.teams.valueSeq().map (team) =>
        div key: team.get('_id'), className: 'team-wrap flex-horiz flex-vcenter',
          TeamName
            large: false
            showSource: true
            showUnread: false
            onClick: @onTeamSwitch
            data: team
          if @state.selectedId is team.get('_id')
            LiteLoadingCircle
              size: 24
              stroke: '#FA6855'

  render: ->
    div className: 'forward-team flex-vert',
      @renderTeamList()
