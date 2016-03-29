cx = require 'classnames'
React = require 'react'

teamActions = require '../actions/team'
routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

keyboard = require '../util/keyboard'
analytics = require '../util/analytics'

div = React.createFactory 'div'
i = React.createFactory 'i'
input = React.createFactory 'input'

module.exports = React.createClass
  displayName: 'setting-teams-create'
  mixins: []

  getInitialState: ->
    teamName: ''

  createTeam: ->
    if @state.teamName.trim().length > 0
      analytics.createTeam()
      teamActions.teamCreate @state.teamName.trim()
      , (resp) ->
        if resp.get('_id')?.length
          routerHandlers.team resp.get('_id')

  onBack: ->
    routerHandlers.settingTeams() # go back

  onCreateTeamComplete: ->
    @createTeam()

  onTeamNameChange: (event) ->
    @setState teamName: event.target.value

  onTeamNameKeydown: (event) ->
    if event.keyCode is keyboard.enter
      @createTeam()

  render: ->
    buttonClassName = cx
      'button': true
      'is-disabled': @state.teamName.length is 0

    div className: 'setting-create-team setting-wrapper',
      div className: 'header',
        i className: 'icon icon-td-arrow-left to-back', onClick: @onBack
        lang.getText 'setting-team-create'
      div className: 'content',
        div className: 'data-team-name',
          input
            className: 'input'
            placeholder: lang.getText 'enter-team-name'
            defaultValue: @state.teamName
            onChange: @onTeamNameChange
            onKeyDown: @onTeamNameKeydown
        div className: buttonClassName, onClick: @onCreateTeamComplete, lang.getText 'create'
