
React = require 'react'
ReactDOM = require 'react-dom'
debounce = require 'debounce'
Immutable = require 'immutable'

lang = require '../locales/lang'
find = require '../util/find'
actions = require '../actions/index'
handlers = require '../handlers'

Icon = React.createFactory require '../module/icon'
Space = React.createFactory require 'react-lite-space'
TeamCard = React.createFactory require './team-card'
TeamHeader = React.createFactory require './team-header'
TeamToolbar = React.createFactory require './team-toolbar'
TeamActivity = React.createFactory require './team-activity'
LiteLoadingCircle = React.createFactory require('react-lite-misc').LoadingCircle

{div, span} = React.DOM

module.exports = React.createClass
  displayName: 'team-overview'

  propTypes:
    team: React.PropTypes.instanceOf(Immutable.Map).isRequired
    user: React.PropTypes.instanceOf(Immutable.Map).isRequired
    teams: React.PropTypes.instanceOf(Immutable.Map).isRequired
    activities: React.PropTypes.instanceOf(Immutable.List).isRequired
    contacts: React.PropTypes.instanceOf(Immutable.List).isRequired
    invitations: React.PropTypes.instanceOf(Immutable.List).isRequired
    isAdmin: React.PropTypes.bool.isRequired

  getInitialState: ->
    hasMore: true

  componentDidMount: ->
    @rootEl = @refs.root
    @debouncedGlobalScroll = debounce @onGlobalScroll, 400
    @rootEl.addEventListener 'wheel', @debouncedGlobalScroll

  componentWillUnmount: ->
    @rootEl.removeEventListener 'wheel', @debouncedGlobalScroll

  # methods

  requestMoreActivities: ->
    _maxId = find.minId(@props.activities)
    actions.activities.get @props.team.get('_id'), _maxId, (resp) =>
      if resp.length is 0
        @setState hasMore: false

  # events

  onGlobalScroll: (event) ->
    if @state.hasMore
      if (@rootEl.clientHeight + @rootEl.scrollTop + 20) > @rootEl.scrollHeight
        @requestMoreActivities()

  onBack: ->
    handlers.router.back()

  # renderers

  # removed header in this milestone
  renderHeader: ->
    _teamId = @props.team.get('_id')

    div className: 'overview-header',
      TeamHeader
        _teamId: _teamId
        team: @props.team
        teams: @props.teams
        router: @props.router
      TeamToolbar
        _teamId: _teamId
        user: @props.user
        router: @props.router

  render: ->
    div className: 'team-overview', ref: 'root',
      div className: 'team-content-wrapper',
        div className: 'team-content',
          div className: 'activities-section',
            div className: 'section-header',
              lang.getText('team-lastest-activities')
            @props.activities.map (activity) =>
              TeamActivity team: @props.team, activity: activity, key: activity.get('_id'), showRemove: @props.isAdmin
            Space height: 40
            div className: 'overview-loading',
              if @props.activities.size is 0
                span className: 'muted', lang.getText('no-activities-yet')
              else if @state.hasMore
                LiteLoadingCircle size: 24
          Space width: 32
          div className: 'card-placeholder',
            TeamCard team: @props.team, contacts: @props.contacts, invitations: @props.invitations
      div className: 'close-icon', onClick: @onBack,
        Icon name: 'remove', size: 16
