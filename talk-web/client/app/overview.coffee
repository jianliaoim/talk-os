React = require 'react'
moment = require 'moment'
Immutable = require 'immutable'

find = require '../util/find'
actions = require '../actions/index'
handlers = require '../handlers/index'

Icon = React.createFactory require '../module/icon'
TeamCard = React.createFactory require './team-card'
ActivityItem = React.createFactory require './activity-item'
TimelineList = React.createFactory require './timeline-list'
ActivitySection = React.createFactory require './activity-section'
ActivityContainer = React.createFactory require './activity-container'

{a, div, li, span, ul} = React.DOM

module.exports = React.createClass

  propTypes:
    team: React.PropTypes.instanceOf(Immutable.Map).isRequired
    stage: React.PropTypes.instanceOf(Immutable.List).isRequired
    contacts: React.PropTypes.instanceOf(Immutable.List).isRequired
    invitations: React.PropTypes.instanceOf(Immutable.List).isRequired
    timelineList: React.PropTypes.instanceOf(Immutable.List).isRequired
    transformedData: React.PropTypes.instanceOf(Immutable.List).isRequired

  onClose: ->
    handlers.router.back()

  onRequestNextActivities: ->
    _maxId = @props.transformedData.last().get('data').last().get('_id')
    actions.activities.getByMaxId @props.team.get('_id'), _maxId

  onRequestPrevActivities: ->
    _minId = @props.transformedData.first().get('data').first().get('_id')
    actions.activities.getByMinId @props.team.get('_id'), _minId

  onRequestSpecificActivities: (maxDate) ->
    _teamId = @props.team.get '_id'
    handlers.router.teamOverview _teamId, maxDate: maxDate
    actions.activities.getByMaxDate _teamId, maxDate

  render: ->
    div className: 'overview',
      TimelineList null,
        @props.timelineList.map (v, k) =>
          div key: k, className: 'timeline-list-content',
            div className: 'timeline-list-year', v.get 'display'
            ul className: 'timeline-list-month-list',
              v.get('months').map (v, k) =>
                onClick = => @onRequestSpecificActivities v.get 'value'
                li key: k,
                  a onClick: onClick, v.get 'display'
      ActivityContainer
        stage: @props.stage
        isEmpty: @props.transformedData.size is 0
        onRequestAfter: @onRequestNextActivities
        onRequestBefore: @onRequestPrevActivities
        @props.transformedData.map (v, k) ->
          ActivitySection key: k, display: v.get('display'),
            if v.get('data').size > 0
              ul className: 'activity-list',
                v.get('data').map (v, k) ->
                  li key: v.get('_id'), className: 'activity-cell',
                    ActivityItem activity: v
      TeamCard
        team: @props.team
        contacts: @props.contacts
        invitations: @props.invitations
      div className: 'close-icon', onClick: @onClose,
        Icon name: 'remove', size: 16
