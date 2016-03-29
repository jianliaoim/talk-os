cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'
teamActions = require '../actions/team'
routerHandlers = require '../handlers/router'

mixinSubscribe = require '../mixin/subscribe'

lang = require '../locales/lang'

orders = require '../util/orders'
analytics = require '../util/analytics'

div = React.createFactory 'div'
i = React.createFactory 'i'
p = React.createFactory 'p'
span =React.createFactory 'span'

module.exports = React.createClass
  displayName: 'setting-teams'
  mixins: [mixinSubscribe]

  getInitialState: ->
    teams: @getTeams()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState teams: @getTeams()

  getTeams: ->
    query.teams(recorder.getState())

  toCreateTeam: ->
    routerHandlers.teamCreate()

  toSyncTeambition: ->
    routerHandlers.teamSync()
    analytics.syncTeam()

  renderTeams: ->
    if @state.teams.size > 0
      div className: 'teams thin-scroll',
        @state.teams.toList()
        .sort orders.byPopularTeam query.teamFootprints(recorder.getState())
        .sortBy (team) -> -1 * team.get('unread')
        .map (team) ->
          onClick = ->
            routerHandlers.team team.get('_id')
            analytics.chooseTeam()
            analytics.enterTeam()
          div className: 'team list', onClick: onClick, key: team.get('_id'),
            i className: 'team-icon',
              if team.get('source') is 'teambition'
                span null, team.get('name')[0],
                  i className: 'team-icon-small icon icon-t'
              else
                span null, team.get('name')[0]
            span className: 'name', team.get('name')
            if team.get('unread') > 0
              span className: 'icon-unread', team.get('unread')

  render: ->
    div className: 'setting-teams setting-wrapper',
      div className: 'header', lang.getText 'setting-teams'
      div className: 'list-content',
        @renderTeams()
        div className: 'create-team list', onClick: @toCreateTeam,
          i className: 'icon icon-plus'
          p className: 'upper', lang.getText 'create-new-team'
          p null, lang.getText 'create-new-team-sub'
        div className: 'sync-team list', onClick: @toSyncTeambition,
          i className: 'icon icon-building'
          p className: 'upper', lang.getText 'sync-with-teambition'
          p null, lang.getText 'sync-with-teambition-sub'
