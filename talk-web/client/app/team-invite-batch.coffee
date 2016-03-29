React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

util = require '../util/util'

teamActions = require '../actions/team'
notifyActions = require '../actions/notify'

{ div, span, textarea } = React.DOM

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-invite-batch'
  mixins: [ PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    contacts: T.instanceOf(Immutable.List).isRequired
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

  onBatchInvite: ->
    if @state.invitees.trim().length isnt 0
      invitees = @makeInvitees @state.invitees
      inviteesNew = []
      max = 100

      if (invitees.length is 0) or not @validInvitees invitees
        notifyActions.error l('room-members-invalid')
      else
        invitees.forEach (invitee) =>
          if not @props.contacts.some((x) -> invitee in [x.get('email'), x.get('phoneForLogin')])
            inviteesNew.push invitee

        if inviteesNew.length > 0 and inviteesNew.length < max
          inviteesNew = @makeData inviteesNew
          teamActions.batchInvite @props._teamId, inviteesNew,
            =>
              @setState invitees: ''
              @props.onClose()
              notifyActions.success l('room-members-success')
            ->
              notifyActions.error l('room-members-error')
        else if inviteesNew.length >= max
          notifyActions.error l('room-members-exceed-maximum').replace '%s', max
        else if invitees.length isnt inviteesNew.length
          notifyActions.error l('room-members-exists')

  onTextareaChange: (event) ->
    @setState invitees: event.target.value

  renderFooter: ->
    div className: 'footer',
      span className: 'button', onClick: @onBatchInvite, l('team-contacts-batch-invite-link')

  render: ->
    div className: 'team-invite-batch',
      div className: 'section',
        l('team-contacts-batch-invite')
        textarea
          autoFocus: true
          className: 'form-control is-static'
          placeholder: l('batch-invite-textarea')
          onChange: @onTextareaChange
      @renderFooter()
