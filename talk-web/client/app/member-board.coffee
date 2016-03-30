React = require 'react'
Immutable = require 'immutable'
cx = require 'classnames'
assign = require 'object-assign'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
mixinQuery = require '../mixin/query'

detect = require '../util/detect'
search = require '../util/search'
orders = require '../util/orders'
analytics = require '../util/analytics'

lang = require '../locales/lang'

contactActions = require '../actions/contact'
teamActions = require '../actions/team'
notifyActions = require '../actions/notify'

Permission = require '../module/permission'
PermissionMember = require '../module/permission-member'

routerHandlers = require '../handlers/router'

Icon = React.createFactory require '../module/icon'
ContactItem = React.createFactory require './contact-item'
TeamInvite = React.createFactory require './team-invite'
TeamInviteBatch = React.createFactory require './team-invite-batch'
SearchBox = React.createFactory require('react-lite-misc').SearchBox
SlimModal = React.createFactory require './slim-modal'
LightDialog = React.createFactory require '../module/light-dialog'

{ a, div, span, input, textarea, noscript } = React.DOM

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'member-board'

  mixins: [PureRenderMixin, mixinQuery]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    contacts: T.instanceOf(Immutable.List).isRequired
    invitations: T.instanceOf(Immutable.List).isRequired
    leftContacts: T.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    showInvite: false
    value: ''

  filterList: (list) ->
    search.forMembers list, @state.value, getAlias: @getContactAlias
    .sort orders.byRoleThenPinyin
    .sort orders.byCreatorId @props._userId

  filterInvitaitions: ->
    search.forInvitations @props.invitations, @state.value

  onChange: (value) ->
    @setState { value }

  onItemClick: (contact) ->
    routerHandlers.chat @props._teamId, contact.get('_id'), {}, @props.onClose
    analytics.switchChatTargetFromContact()

  renderList: ->
    if @filterList(@props.contacts).size + @filterInvitaitions().size + @filterList(@props.leftContacts).size > 0
      div className: 'member-list thin-scroll flex-fill',
        @renderContacts()
        @renderInvitations()
        @renderLeftContacts()
    else
      div className: 'member-list thin-scroll flex-fill',
        span className: 'muted contact-item placeholder', l('no-contact-result')

  renderContacts: ->
    filteredList = @filterList(@props.contacts)
    if filteredList.size > 0
      filteredList.map (contact) =>
        onItemClick = =>
          @onItemClick contact

        ContactItem
          key: contact.get('_id')
          contact: contact
          _teamId: @props._teamId
          onClick: onItemClick
          div className: 'action',
            @renderMemeberHandlerset(contact)

  renderInvitations: ->
    @filterInvitaitions().map (invitation) =>
      ContactItem
        key: invitation.get('_id')
        _teamId: @props._teamId
        contact: invitation
        invitations: @props.invitations
        isInvite: true
        showAction: true
        div className: 'action',
          @renderInvitationHandlerset(invitation)

  renderLeftContacts: ->
    filteredLeftContacts = @filterList(@props.leftContacts)
    if filteredLeftContacts.size > 0
      filteredLeftContacts.map (contact) =>
        onItemClick = =>
          @onItemClick contact

        ContactItem
          key: contact.get('_id')
          _teamId: @props._teamId
          contact: contact
          onClick: onItemClick
          showAction: false

  renderSearch: ->
    div className: 'search flex-static flex-horiz',
      SearchBox
        value: @state.value
        onChange:  @onChange
        locale: lang.getText('search-members')
        autoFocus: false

  renderFooter: ->
    div className: 'footer member-invite flex-horiz flex-static',
      div className: 'button', onClick: @onInviteShow,
        Icon name: 'user-add', size: 18
        span className: 'text', lang.getText('invite-members')

  onInviteClose: ->
    @setState showInvite: false

  onInviteShow: ->
    @setState showInvite: 'invite'

  switchInviteType: ->
    showInvite =
      switch @state.showInvite
        when 'invite' then 'batch-invite'
        when 'batch-invite' then 'invite'

    @setState { showInvite }

  renderInviteModal: ->
    showInvite = @state.showInvite
    show = @state.showInvite in ['batch-invite', 'invite']

    props = assign { show: show, color: 'green', onClose: @onInviteClose },
      { name: 'team-invite', title: l('team-entrance-invite') } if showInvite is 'invite'
      { name: 'team-invite-batch', onBack: @switchInviteType } if showInvite is 'batch-invite'

    SlimModal props,
      switch showInvite
        when 'invite'
          TeamInvite
            _teamId: @props._teamId
            contacts: @props.contacts
            invitations: @props.invitations
            onBatchInviteClick: @switchInviteType
        when 'batch-invite'
          TeamInviteBatch
            _teamId: @props._teamId
            contacts: @props.contacts
            invitations: @props.invitations
            onClose: @onInviteClose

  renderMemeberHandlerset: (contact) ->
    MemberItemHandlersetPermission
      _teamId: @props._teamId
      _userId: @props._userId
      contact: contact

  renderInvitationHandlerset: (invitation) ->
    InvitationHandlersetPermission
      _teamId: @props._teamId
      invitations: @props.invitations
      invitation: invitation

  render: ->
    div className: 'member-board flex-vert flex-fill flex-space',
      @renderSearch()
      @renderList()
      @renderFooter()
      @renderInviteModal()

MemberItemHandlersetClass = React.createClass
  displayName: 'member-item-handlerset'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    contact: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showConfirm: false

  isMe: ->
    @props.contact.get('_id') is @props._userId

  onDemote: (event) ->
    event.stopPropagation()

    contactActions.contactUpdateRole @props._teamId, @props.contact.get('_id'), 'member'

  onPromote: (event) ->
    event.stopPropagation()

    contactActions.contactUpdateRole @props._teamId, @props.contact.get('_id'), 'admin'

  onRemove: (event) ->
    event.stopPropagation()

    @setState showConfirm: true

  onRemoveClick: ->
    contactId = @props.contact.get('_id')
    contactActions.contactRemove @props._teamId, @props.contact, =>
      if contactId is recorder.getState().getIn(['router', 'data', '_toId'])
        routerHandlers.team @props._teamId

  onCloseConfirm: ->
    @setState showConfirm: false

  renderDeleter: ->
    LightDialog
      flexible: true
      show: @state.showConfirm
      onCloseClick: @onCloseConfirm
      onConfirm: @onRemoveClick
      confirm: l('confirm')
      cancel: l('cancel')
      content: lang.getText('confirm-delete-topic-member')

  render: ->
    unless @isMe()
      div className: 'handlerset line',
        unless @props.contact.get('isRobot')
          if @props.contact.get('role') is 'admin'
            span
              className: 'team-contacts-demote',
              onClick: @onDemote
              lang.getText('team-contacts-demote')
          else
            span
              className: 'team-contacts-promote',
              onClick: @onPromote
              lang.getText('team-contacts-promote')
        unless detect.isTalkai(@props.contact)
          span className: 'team-contacts-remove', onClick: @onRemove, lang.getText('team-contacts-remove')
        @renderDeleter()
    else
      noscript()

InvitationHandlersetClass = React.createClass
  displayName: 'invitation-handlerset'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    invitations: T.instanceOf(Immutable.List).isRequired
    invitation: T.instanceOf(Immutable.Map).isRequired

  onRemoveInvite: (event) ->
    event.stopPropagation()

    success = ->
      notifyActions.success lang.getText('succeed-removing-invitation')
    @props.invitations
    .filter (invitation) =>
      invitation.get('key') is @props.invitation.get('key')
    .forEach (invitation) ->
      teamActions.removeInvite invitation.get('_id'), success

  render: ->
    div className: 'handlerset',
      span
        className: 'team-contacts-remove',
        onClick: @onRemoveInvite
        lang.getText('team-contacts-remove')

InvitationHandlersetPermission = React.createFactory Permission.create(InvitationHandlersetClass, Permission.admin)
MemberItemHandlersetPermission = React.createFactory PermissionMember.create(MemberItemHandlersetClass)
