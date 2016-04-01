
React = require 'react'
assign = require 'object-assign'
Immutable = require 'immutable'

lang = require '../locales/lang'
handlers = require '../handlers'

Icon = React.createFactory require '../module/icon'
Space = React.createFactory require 'react-lite-space'
SlimModal = React.createFactory require './slim-modal'
MembersRow = React.createFactory require '../app/members-row'
TeamInvite = React.createFactory require './team-invite'
TeamInviteBatch = React.createFactory require './team-invite-batch'

{div} = React.DOM

module.exports = React.createClass
  displayName: 'team-card'

  propTypes:
    team: React.PropTypes.instanceOf(Immutable.Map).isRequired
    contacts: React.PropTypes.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    showInvite: false

  onClick: ->
    handlers.router.team @props.team.get('_id')

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
      { name: 'team-invite', title: lang.getText('team-entrance-invite') } if showInvite is 'invite'
      { name: 'team-invite-batch', onBack: @switchInviteType } if showInvite is 'batch-invite'

    SlimModal props,
      switch showInvite
        when 'invite'
          TeamInvite
            _teamId: @props.team.get('_id')
            contacts: @props.contacts
            invitations: @props.invitations
            onBatchInviteClick: @switchInviteType
        when 'batch-invite'
          TeamInviteBatch
            _teamId: @props.team.get('_id')
            contacts: @props.contacts
            invitations: @props.invitations
            onClose: @onInviteClose

  render: ->
    firstLetter = @props.team.get('name')[0]
    visibleMemberIds = @props.contacts
    .filterNot (contact) -> contact.get('isRobot')
    .map (contact) -> contact.get('_id')

    div className: 'team-card',
      div className: 'team-card-title', lang.getText 'team-info'
      div className: 'card-detail',
        if @props.team.has('logoUrl')
          style = backgroundImage: "url(#{@props.team.get('logoUrl')})"
          div className: 'card-logo', style: style
        else
          div className: 'card-logo', firstLetter
        div className: 'card-title', onClick: @onClick, @props.team.get('name')
        div className: 'card-text', @props.team.get('description')
        MembersRow
          _teamId: @props.team.get('_id')
          _memberIds: visibleMemberIds
          contacts: @props.contacts
          onChange: ->
          isEditable: false
      div className: 'card-footer', onClick: @onInviteShow,
        Icon size: 16, name: 'plus'
        Space width: 8
        lang.getText('invite-new-members')
      @renderInviteModal()
