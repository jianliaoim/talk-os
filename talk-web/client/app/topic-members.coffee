
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'
mixinQuery = require '../mixin/query'

util = require '../util/util'
detect = require '../util/detect'
orders = require '../util/orders'
search = require '../util/search'
keyboard = require '../util/keyboard'

mixinSubscribe = require '../mixin/subscribe'

notifyActions = require '../actions/notify'
roomActions   = require '../actions/room'
teamActions   = require '../actions/team'

SwitchTabs = React.createFactory require('react-lite-misc').SwitchTabs
LiteDialog  = React.createFactory require('react-lite-layered').Dialog
MemberItem = React.createFactory require './member-item'

div    = React.createFactory 'div'
span   = React.createFactory 'span'
button = React.createFactory 'button'
a      = React.createFactory 'a'
input  = React.createFactory 'input'

T = React.PropTypes
ReactCSSTransitionGroup = React.createFactory require 'react-addons-css-transition-group'

tabs = ['room-members-members', 'room-members-contact']

module.exports = React.createClass
  displayName: 'topic-members'
  mixins: [mixinSubscribe, PureRenderMixin, mixinQuery]

  propTypes:
    topic:    T.instanceOf(Immutable.Map)
    onClose:  T.func.isRequired

  getInitialState: ->
    tab: tabs[0]
    user: query.user(recorder.getState())
    email: ''
    team: query.teamBy(recorder.getState(), @props.topic.get('_teamId'))
    query: ''
    invitee: ''
    invitations: @getAllInvitations()
    showConfirm: false
    memberToDelete: null
    members: @getMembers()
    contacts: @getContacts()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        members: @getMembers()
        contacts: @getContacts()
        invitations: @getAllInvitations()

  getMembers: ->
    query.membersBy(recorder.getState(), @props.topic.get('_teamId'), @props.topic.get('_id'))

  getContacts: ->
    query.contactsBy(recorder.getState(), @props.topic.get('_teamId'))

  getAllInvitations: ->
    query.invitationsBy(recorder.getState(), @props.topic.get('_teamId')) or Immutable.List()

  getUniqueInvitations: ->
    @state.invitations
    .groupBy((cursor) -> cursor.get('key'))
    .map((cursor) -> cursor.first())
    .toList()

  getInvitations: ->
    @state.invitations
    .filter (invitation) =>
      invitation.get('_roomId') is @props.topic.get('_id')

  onTabClick: (tab) ->  @setState {tab, query: ''}

  onJoinClick: (contact) ->
    Invitee =
      if contact?
        _userId: contact.get '_id'
      else null
    if Invitee?
      roomActions.roomInvite @props.topic.get('_id'), Invitee,
        ->
          notifyActions.success lang.getText 'room-members-success'
        ->
          notifyActions.error lang.getText 'room-members-error'

  onJoinInvitationClick: (invitation) ->
    @setState
      invitee: invitation.get('mobile') or invitation.get('email')
      , @onSubmit

  onInviteChange: (event) -> @setState invitee: event.target.value

  onInputKeydown: (event) ->
    if event.keyCode is keyboard.enter
      @onSubmit()

  onSubmit: ->
    invitee = @state.invitee
    if invitee.length and not (util.isEmail(invitee) or util.isMobile(invitee))
      notifyActions.error lang.getText 'room-members-invalid'
    else if @state.members.some((x) -> invitee in [x.get('email'), x.get('mobile')])
      notifyActions.error lang.getText 'room-members-exists'
    else if @getInvitations().some((x) -> invitee in [x.get('email'), x.get('mobile')])
      notifyActions.error lang.getText 'room-members-exists'
    else if @state.contacts.some((x) -> invitee in [x.get('email'), x.get('mobile')])
      contact = @state.contacts.find (contact) ->
        invitee in [contact.get('email'), contact.get('mobile')]
      @onJoinClick contact
      @setState invitee: ''
    else
      Invitee =
        if util.isEmail invitee
          email: invitee
        else if util.isMobile invitee
          mobile: invitee
        else undefined
      if Invitee?
        roomActions.roomInvite @props.topic.get('_id'), Invitee,
          =>
            @setState invitee: ''

            notifyActions.success lang.getText 'room-members-success'
          ->
            notifyActions.error lang.getText 'room-members-error'

  onQueryChange: (event) ->
    @setState query: event.target.value

  onDeleteClick: ->
    if @state.memberToDelete?
      roomActions.roomRemoveMember @state.memberToDelete
    @setState
      showConfirm: false
      memberToDelete: null

  onShowConfirm: (_teamId, _roomId, _userId) ->
    @setState
      showConfirm: true
      memberToDelete: {_teamId, _roomId, _userId}

  onCloseConfirm: ->
    @setState showConfirm: false

  onRemoveInvite: (_invitationId) ->
    teamActions.removeInvite _invitationId

  renderConfirmModal: ->
    LiteDialog
      cancel: lang.getText('cancel')
      confirm: lang.getText('confirm')
      content: lang.getText('confirm-delete-topic-member')
      flexible: true
      show: @state.showConfirm
      onCloseClick: @onCloseConfirm
      onConfirm: @onDeleteClick

  renderMembers: ->
    creatorId = @props.topic.get('_creatorId')

    currentUserId = @state.user.get('_id')
    currentRoom = query.topicsByOne(recorder.getState(), @props.topic.get('_teamId'), @props.topic.get('_id'))
    isTopicCreator = currentUserId is creatorId

    canRemoveMember = currentRoom.get('isPrivate') and isTopicCreator  # right to remove member `private` topics

    userContact = @state.contacts.find (contact) ->
      contact.get('_id') is currentUserId
    isAdmin = userContact?.get('role') in ['owner', 'admin']
    canRemoveRobot = isAdmin or isTopicCreator   # right to remove `robot` in topics

    div className: 'members',
      ReactCSSTransitionGroup
        transitionName: 'fade'
        component: 'div'
        transitionEnterTimeout: 200
        transitionLeaveTimeout: 200
        @state.members.concat()
          .sort orders.byCreatorIdThenPinyin(creatorId)
          .map (member) =>
            isTopicCreator = member.get('_id') is creatorId
            canRemove = canRemoveMember or member.get('isRobot') and canRemoveRobot
            onRemoveClick = =>
              @onShowConfirm @props.topic.get('_teamId'), @props.topic.get('_id'), member.get('_id')

            div className: 'member-wrap', key: member.get('_id'),
              MemberItem member: member, user: @state.user, _teamId: @props.topic.get('_teamId'), isTopicCreator: isTopicCreator,
              if canRemove and member.get('_id') isnt currentUserId
                div className: 'handlerset',
                  a className: 'button is-small is-danger', onClick: onRemoveClick,
                    lang.getText('team-contacts-remove')
        @renderInvitations()

  renderContacts: ->
    contacts = @state.contacts.filter (contact) -> not detect.isTalkai(contact)
    remainHeight = (contacts.size + @getUniqueInvitations().size) * 75

    if @state.tab is 'room-members-contact'
      contacts = search.forMembers contacts, @state.query, getAlias: @getContactAlias
    style =
      height: "#{remainHeight}px" #remain filter result height immutable

    div className: 'contacts', style: style,
      if contacts.size
        contacts
        .sort orders.byRoleThenPinyin
        .map (contact) =>
          isInTopic = (@state.members.find (member) -> member.get('_id') is contact.get('_id'))?
          onContactClick = =>
            @onJoinClick contact

          MemberItem key: contact.get('_id'), member: contact, user: @state.user, _teamId: @props.topic.get('_teamId'),
            if isInTopic
              span className: 'room-members-joined',
                lang.getText('joined')
            else
              a className: 'button is-primary is-small room-members-join', onClick: onContactClick,
                lang.getText('invite')
      else
        div className: 'muted', lang.getText('no-more-results')
      if @state.query?.trim().length is 0
        @renderUniqueInvitations()

  renderInvitations: ->
    @getInvitations()
    .map (invitation) =>
      isTopicCreator = @state.user.get('_id') is @props.topic.get('_creatorId')
      canRemoveInvitation = @props.topic.get('isPrivate') and isTopicCreator
      onInvitationClick = =>
        @onRemoveInvite(invitation.get('_id'))
      div key: invitation.get('_id'), className: 'member-wrap',
        MemberItem _teamId: @props.topic.get('_teamId'), user: @state.user, member: invitation,
          if canRemoveInvitation
            div className: 'handlerset',
              a className: 'button is-small is-danger', onClick: onInvitationClick,
                lang.getText('team-contacts-remove')

  renderUniqueInvitations: ->
    @getUniqueInvitations()
    .map (invitation) =>
      isInTopic = (@state.invitations.find (member) => member.get('key') is invitation.get('key') and member.get('_roomId') is @props.topic.get('_id'))?
      onInvitationClick = =>
        @onJoinInvitationClick invitation
      div key: invitation.get('_id'), className: 'member-wrap',
        MemberItem _teamId: @props.topic.get('_teamId'), user: @state.user, member: invitation,
          if isInTopic
            span className: 'room-members-joined',
              lang.getText('joined')
          else
            a className: 'button is-primary is-small room-members-join', onClick: onInvitationClick,
              lang.getText('invite')

  renderInvite: ->
    div className: 'anotated-input',
      input
        type: 'text'
        value: @state.invitee
        className: 'form-control'
        placeholder: lang.getText('enter-mobile-or-email')
        onChange: @onInviteChange
        onKeyDown: @onInputKeydown
      a className: 'link-icon', onClick: @onSubmit,
        lang.getText('room-members-do')
      div className: 'room-members-complete'

  renderFilter: ->
    div className: '',
      input
        type: 'text'
        className: 'form-control'
        placeholder: lang.getText('filter-members')
        value: @state.query
        onChange: @onQueryChange

  render: ->
    div className: 'topic-members',
      SwitchTabs
        data: tabs, tab: @state.tab
        onTabClick: @onTabClick
        getText: lang.getText
      div className: 'lm-content',
        if @state.tab is 'room-members-contact'
          @renderFilter()
        else
          @renderInvite()
        switch @state.tab
          when 'room-members-members'
            @renderMembers()
          when 'room-members-contact'
            @renderContacts()
      @renderConfirmModal()
