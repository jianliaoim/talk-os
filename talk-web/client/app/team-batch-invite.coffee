classnames = require 'classnames'
React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

teamActions = require '../actions/team'
notifyActions = require '../actions/notify'

lang = require '../locales/lang'
util = require '../util/util'

div = React.createFactory 'div'
button = React.createFactory 'button'
textarea = React.createFactory 'textarea'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-batch-invite'
  mixins: [PureRenderMixin]

  propTypes:
    data: T.instanceOf Immutable.List
    team: T.object.isRequired
    onClose: T.func.isRequired

  getInitialState: ->
    invitees: ''

  makeInvitees: (data) ->
    arr = []
    data = data.split /\s|,|;/
    data.forEach (el) ->
      if el.length > 0
        arr.push el
    arr

  makeData: (data) ->
    data = Immutable.fromJS data
    data
    .groupBy (el) ->
      if util.isEmail el
        'emails'
      else if util.isMobile el
        'mobiles'
    .toJS()


  validInvitees: (data) ->
    data.every (el) ->
      util.isMobile(el) or util.isEmail(el)

  onSubmit: ->
    if @state.invitees.trim().length isnt 0
      invitees = @makeInvitees @state.invitees
      inviteesNew = []
      max = 100

      if (invitees.length is 0) or not @validInvitees invitees
        notifyActions.error lang.getText 'room-members-invalid'
      else
        invitees.forEach (invitee) =>
          if not @props.data.some((x) -> invitee in [x.get('email'), x.get('phoneForLogin')])
            inviteesNew.push invitee

        if inviteesNew.length > 0 and inviteesNew.length < max
          inviteesNew = @makeData inviteesNew
          teamActions.batchInvite @props.team.get('_id'), inviteesNew,
            =>
              @setState invitees: ''
              @props.onClose()
              notifyActions.success lang.getText('room-members-success')
            ->
              notifyActions.error lang.getText('room-members-error')
        else if inviteesNew.length >= max
          notifyActions.error lang.getText('room-members-exceed-maximum').replace '%s', max
        else if invitees.length isnt inviteesNew.length
          notifyActions.error lang.getText('room-members-exists')

  onTextareaChange: (event) ->
    @setState invitees: event.target.value

  render: ->
    classNameButton = classnames
      'button': true
      'invite-submit': true
      'is-disabled': @state.invitees.length is 0

    div className: 'team-batch-invite',
      textarea
        className: 'email-textarea form-control'
        placeholder: lang.getText 'batch-invite-textarea'
        onChange: @onTextareaChange
      button
        className: classNameButton
        onClick: @onSubmit
        lang.getText 'team-contacts-do'
