React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'

util = require '../util/util'
detect = require '../util/detect'
orders = require '../util/orders'
keyboard = require '../util/keyboard'

teamActions = require '../actions/team'
notifyActions = require '../actions/notify'
contactActions = require '../actions/contact'
routerHandlers = require '../handlers/router'

TeamPrefs = React.createFactory require './team-prefs'
MemberItem = React.createFactory require './member-item'
TeamBatchInvite = React.createFactory require './team-batch-invite'

Permission = require '../module/permission'
PermissionMember = require '../module/permission-member'

LightModal = React.createFactory require '../module/light-modal'

a = React.createFactory 'a'
p = React.createFactory 'p'
div = React.createFactory 'div'
span = React.createFactory 'span'
input = React.createFactory 'input'
label = React.createFactory 'label'

T = React.PropTypes

ReactCSSTransitionGroup = React.createFactory require 'react-addons-css-transition-group'

module.exports = React.createClass
  displayName: 'team-contacts'
  mixins: [PureRenderMixin]

  propTypes:
    data: T.instanceOf(Immutable.List).isRequired
    team: T.object.isRequired
    invitations: T.instanceOf(Immutable.List).isRequired
    onSwitchTab: T.func.isRequired

  getInitialState: ->
    invitee: ''
    showPrefEditor: false
    showTeamBatchInvite: false

  getUniqueInvitations: ->
    @props.invitations
    .groupBy((cursor) -> cursor.get('key'))
    .map((cursor) -> cursor.first())
    .toList()

  sendInvite: ->
    invitee = @state.invitee

    if invitee.length and not (util.isEmail(invitee) or util.isMobile(invitee))
      notifyActions.error lang.getText 'room-members-invalid'
    else if @props.data.some((x) -> invitee in [x.get('email'), x.get('phoneForLogin')])
      notifyActions.error lang.getText 'room-members-exists'
    else if @getUniqueInvitations().some((x) -> invitee in [x.get('email'), x.get('phoneForLogin')])
      notifyActions.error lang.getText 'room-members-exists'
    else
      if util.isEmail invitee
        Invitee = email: invitee
      else if util.isMobile invitee
        Invitee = mobile: invitee
      if Invitee?
        teamActions.teamInvite @props.team.get('_id'), Invitee,
          =>
            @setState invitee: ''

            if @props.data.some((x) -> invitee in [x.get('email'), x.get('mobile')])
              notifyActions.success lang.getText('room-members-added')
            else if @getUniqueInvitations().some((x) -> invitee in [x.get('email'), x.get('mobile')])
              notifyActions.success lang.getText('room-members-invited')
            else
              notifyActions.success lang.getText('room-members-success')
          ->
            notifyActions.error lang.getText('room-members-error')

  onInviteChange: (event) ->
    invitee = event.target.value
    @setState {invitee}

  onInviteKeydown: (event) ->
    if event.keyCode is keyboard.enter
      event.preventDefault()
      @sendInvite()

  onLinkClick: (event) ->
    event.target.select()

  onSwitchTab: ->
    @props.onSwitchTab()

  onTeamBatchInviteHide: ->
    @setState showTeamBatchInvite: false

  onTeamBatchInviteShow: ->
    @setState showTeamBatchInvite: true

  onPrefEditorShow: ->
    @setState showPrefEditor: true

  onPrefEditorHide: ->
    @setState showPrefEditor: false

  renderNonjoinHint: ->
    [text1, text2, text3, text4] = lang.getText('redirect-syncing-member').split('%s')
    p className: 'form-group muted',
      text1
      a className: 'button is-link', target: '_blank', href: @props.team.get('sourceUrl'),
        @props.team.get('sourceName')
      text2
      @props.team.get('source')
      text3
      a className: 'button is-link', onClick: @onSwitchTab,
        lang.getText('member-syncing')
      text4

  renderPrefEditor: ->
    LightModal
      name: 'team-prefs'
      title: lang.getText('team-prefs-edit')
      show: @state.showPrefEditor
      onCloseClick: @onPrefEditorHide
      TeamPrefs
        user: @props.user
        team: @props.team
        close: @onPrefEditorHide

  renderContacts: ->
    @props.data
    .sort orders.byRoleThenPinyin
    .sort orders.byCreatorId @props.user.get('_id')
    .map (contact) =>
      isMe = @props.user.get('_id') is contact.get('_id')

      MemberItem
        key: contact.get('_id'), member: contact, user: @props.user, _teamId: @props.team.get('_id')
        if isMe
          div className: 'handlerset is-me',
            a
              className: 'button is-small is-primary team-contacts-demote', onClick: @onPrefEditorShow,
              lang.getText('team-prefs-edit')
        else
          MemberItemHandlersetPermission
            _teamId: @props.team.get('_id')
            contact: contact

  renderInvitations: ->
    @getUniqueInvitations()
    .map (invitation) =>
      MemberItem
        _teamId: @props.team.get('_id')
        key: invitation.get '_id'
        user: @props.user
        member: invitation
        InvitationHandlersetPermission
          _teamId: @props.team.get('_id')
          invitations: @props.invitations
          invitation: invitation

  renderTeamBatchInvite: ->
    LightModal
      name: 'team-batch-invite'
      title: lang.getText('team-contacts-batch-invite')
      show: @state.showTeamBatchInvite
      onCloseClick: @onTeamBatchInviteHide
      TeamBatchInvite
        data: @props.data
        team: @props.team
        onClose: @onTeamBatchInviteHide

  renderInviteForm: ->
    div className: 'form-group',
      label null, lang.getText 'invite-people'
      a className: 'link-icon link-batch-invite', onClick: @onTeamBatchInviteShow,
        span className: 'ti ti-users'
        lang.getText('team-contacts-batch-invite-link')
      div className: 'anotated-input',
        input
          type: 'text'
          value: @state.invitee, onKeyDown: @onInviteKeydown
          className: 'form-control'
          placeholder: lang.getText('enter-mobile-or-email')
          onChange: @onInviteChange
        a className: 'link-icon', onClick: @sendInvite, lang.getText('team-contacts-do')
      @renderTeamBatchInvite()

  render: ->
    div className: 'team-contacts lm-content',
      @renderInviteForm()
      div className: 'form-group',
        label null, lang.getText('team-contacts-link')
        div className: 'anotated-input',
          input
            type: 'text', className: 'team-contacts-link form-control'
            value: @props.team.get('inviteUrl'), onChange: (->), onClick: @onLinkClick
          ResetInviteUrlPermission
            _teamId: @props.team.get('_id')
      div className: 'team-contacts-joined modal-paragraph',
        div className: 'modal-name',
          lang.getText('team-contacts-guide')
          '・'
          @props.data.size
        ReactCSSTransitionGroup
          transitionName: 'fade'
          component: 'div',
          transitionEnterTimeout: 200
          transitionLeaveTimeout: 200
          @renderContacts()
          @renderInvitations()
          @renderPrefEditor()


MemberItemHandlersetClass = React.createClass
  displayName: 'member-item-handlerset'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    contact: T.instanceOf(Immutable.Map).isRequired

  onDemote: ->
    contactActions.contactUpdateRole @props._teamId, @props.contact.get('_id'), 'member'

  onPromote: ->
    contactActions.contactUpdateRole @props._teamId, @props.contact.get('_id'), 'admin'

  onRemove: ->
    contactId = @props.contact.get('_id')
    contactActions.contactRemove @props._teamId, @props.contact, =>
      if contactId is recorder.getState().getIn(['router', 'data', '_toId'])
        routerHandlers.team @props._teamId

  render: ->
    div className: 'handlerset',
      unless @props.contact.get('isRobot')
        if @props.contact.get('role') is 'admin'
          a
            className: 'button is-small is-default team-contacts-demote',
            onClick: @onDemote
            lang.getText('team-contacts-demote')
        else
          a
            className: 'button is-primary is-small team-contacts-promote',
            onClick: @onPromote
            lang.getText('team-contacts-promote')
      unless detect.isTalkai(@props.contact)
        a
          className: 'button is-small is-danger team-contacts-remove',
          onClick: @onRemove
          lang.getText('team-contacts-remove')


InvitationHandlersetClass = React.createClass
  displayName: 'invitation-handlerset'

  mixins: [PureRenderMixin]

  propTypes:
    invitations: T.instanceOf(Immutable.List).isRequired
    invitation: T.instanceOf(Immutable.Map).isRequired

  onRemoveInvite: ->
    success = ->
      notifyActions.success lang.getText('succeed-removing-invitation')
    @props.invitations
    .filter (invitation) =>
      invitation.get('key') is @props.invitation.get('key')
    .forEach (invitation) ->
      teamActions.removeInvite invitation.get('_id'), success

  render: ->
    div className: 'handlerset',
      a
        className: 'button is-small is-danger team-contacts-remove',
        onClick: @onRemoveInvite
        lang.getText('team-contacts-remove')


ResetInviteUrlClass = React.createClass
  displayName: 'reset-invite-url'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired

  resetUrl: ->
    teamActions.resetInviteUrl @props._teamId

  render: ->
    a className: 'link-icon', onClick: @resetUrl, lang.getText('reset')


MemberItemHandlersetPermission = React.createFactory PermissionMember.create(MemberItemHandlersetClass)
InvitationHandlersetPermission = React.createFactory Permission.create(InvitationHandlersetClass, Permission.admin)
ResetInviteUrlPermission = React.createFactory Permission.create(ResetInviteUrlClass, Permission.admin)
