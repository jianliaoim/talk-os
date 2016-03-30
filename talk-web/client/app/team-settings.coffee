React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang        = require '../locales/lang'

teamActions = require '../actions/team'
routerHandlers = require '../handlers/router'

LightDialog = React.createFactory require '../module/light-dialog'

div    = React.createFactory 'div'
p      = React.createFactory 'p'
a      = React.createFactory 'a'
button = React.createFactory 'button'

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-settings'

  mixins: [PureRenderMixin]

  propTypes:
    data:           T.instanceOf(Immutable.Map)

  onQuitTeam: ->
    routerHandlers.settingTeams()
    _userId = query.userId(recorder.getState())
    data =
      _teamId: @props.data.get('_id')
      _userId: _userId
    teamActions.teamLeave @props.data.get('_id'), data

  renderLeave: ->
    div className: 'form-group',
      p className: 'modal-name', l('quit-team')
      p className: 'muted', l('warning-quit-team')
      button className: 'button is-danger is-extended', onClick: @onQuitTeam,
        l('quit-team')

  render: ->
    div className: 'team-settings lm-content',
      @renderLeave()
