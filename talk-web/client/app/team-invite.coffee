React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'

util = require '../util/util'
detect = require '../util/detect'
keyboard = require '../util/keyboard'

mixinSubscribe = require '../mixin/subscribe'

teamActions = require '../actions/team'
notifyActions = require '../actions/notify'

TeamPrefs = React.createFactory require './team-prefs'

Permission = require '../module/permission'

{ a, div, span, input, button, textarea, noscript } = React.DOM

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-invite'
  mixins: [ PureRenderMixin, mixinSubscribe ]

  propTypes:
    _teamId: T.string.isRequired
    contacts: T.instanceOf(Immutable.List).isRequired
    invitations: T.instanceOf(Immutable.List).isRequired
    onBatchInviteClick: T.func.isRequired

  getInitialState: ->
    type: 'invite'
    team: @getTeam()
    invitee: ''
    invitees: ''

  componentDidMount: ->
    @subscribe recorder, =>
      @setState team: @getTeam()

  getTeam: ->
    query.teamBy recorder.getState(), @props._teamId

  getUniqueInvitations: ->
    @props.invitations
    .groupBy((cursor) -> cursor.get('key'))
    .map((cursor) -> cursor.first())
    .toList()

  sendInvite: ->
    invitee = @state.invitee

    if invitee.length and not (util.isEmail(invitee) or util.isMobile(invitee))
      notifyActions.error l('room-members-invalid')
    else if @props.contacts.some((x) -> invitee in [x.get('email'), x.get('phoneForLogin')])
      notifyActions.error l('room-members-exists')
    else if @getUniqueInvitations().some((x) -> invitee in [x.get('email'), x.get('phoneForLogin')])
      notifyActions.error l('room-members-exists')
    else
      if util.isEmail invitee
        Invitee = email: invitee
      else if util.isMobile invitee
        Invitee = mobile: invitee
      if Invitee?
        teamActions.teamInvite @props._teamId, Invitee,
          =>
            @setState invitee: ''

            if @props.contacts.some((x) -> invitee in [x.get('email'), x.get('mobile')])
              notifyActions.success l('room-members-added')
            else if @getUniqueInvitations().some((x) -> invitee in [x.get('email'), x.get('mobile')])
              notifyActions.success l('room-members-invited')
            else
              notifyActions.success l('room-members-success')
          ->
            notifyActions.error l('room-members-error')

  onLinkClick: (event) ->
    event.target.select()

  onInviteChange: (event) ->
    invitee = event.target.value
    @setState {invitee}

  onInviteKeydown: (event) ->
    if event.keyCode is keyboard.enter
      event.preventDefault()
      @sendInvite()

  renderInviteForm: ->
    div className: 'section',
      span className: 'flex-horiz flex-between',
        l('invite-people')
        span className: 'flex-horiz flex-vcenter line', onClick: @props.onBatchInviteClick,
          span className: 'muted', l('or')
          span className: 'button is-link', l('team-contacts-batch-invite-link')
      div className: 'anotated-input',
        input
          type: 'text'
          value: @state.invitee, onKeyDown: @onInviteKeydown
          className: 'form-control'
          placeholder: l('enter-mobile-or-email')
          autoFocus: true
          onChange: @onInviteChange

  render: ->
    div className: 'team-invite',
      @renderInviteForm()
      div className: 'section',
        l('team-contacts-link')
        div className: 'anotated-input',
          input
            type: 'text', className: 'team-contacts-link form-control'
            value: @state.team.get('inviteUrl'), onChange: (->), onClick: @onLinkClick
          ResetInviteUrlPermission
            _teamId: @props._teamId
      div className: 'footer',
        span className: 'button', onClick: @sendInvite, l('team-contacts-do')

ResetInviteUrlClass = React.createClass
  displayName: 'reset-invite-url'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired

  resetUrl: ->
    teamActions.resetInviteUrl @props._teamId

  render: ->
    span className: 'link-icon', onClick: @resetUrl, l('reset')

ResetInviteUrlPermission = React.createFactory Permission.create(ResetInviteUrlClass, Permission.admin)
