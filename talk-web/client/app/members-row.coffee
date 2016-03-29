cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

mixinUser = require '../mixin/user'
mixinModal = require '../mixin/modal'
mixinSubscribe = require '../mixin/subscribe'

RosterManagement = React.createFactory require './roster-management'

Tooltip = React.createFactory require '../module/tooltip'
SlimModal = React.createFactory require './slim-modal'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ i, div, span } = React.DOM
T = React.PropTypes

lang = require '../locales/lang'

module.exports = React.createClass
  displayName: 'members-row'
  mixins: [ mixinModal, mixinSubscribe, mixinUser, PureRenderMixin ]

  propsTypes:
    _teamId: T.string.isRequired
    _memberIds: T.instanceOf(Immutable.List).isRequired
    contacts: T.instanceOf(Immutable.List).isRequired
    onChange: T.func.isRequired
    isEditable: T.bool
    maxNum: T.number

  getDefaultProps: ->
    isEditable: false

  beyondMaxNum: ->
    @props.maxNum? and @props.maxNum < @props._memberIds.size

  onClickPlus: ->
    @onOpenModal()

  onRemoveMember: (_id) ->
    if @props.isEditable
      _memberIds = @props._memberIds.filterNot (_memberId) ->
        _memberId is _id
      @props.onChange(_memberIds)

  handleSubmitMember: (memberIds) ->
    @props.onChange memberIds

  renderRosterManagement: ->
    SlimModal
      name: 'roster-management'
      title: lang.getText('invite-members')
      show: @state.showModal
      onClose: @onCloseModal
      RosterManagement
        _teamId: @props._teamId
        onClose: @onCloseModal
        isRemovable: true
        onSubmit: @handleSubmitMember
        selectedContacts: @props._memberIds

  renderMember: (member) ->
    classIcon = cx 'icon', 'icon-remove'
    classAvatar = cx 'cell', 'avatar-small', 'round'
    styleAvatar =
      if member.has('avatarUrl') and member.get('avatarUrl').length > 0
        backgroundImage: "url(#{ member.get('avatarUrl') })"
      else
        {}
    onClickAvatar = (e) =>
      e.stopPropagation()
      @onRemoveMember member.get('_id')

    Tooltip key: member.get('_id'), template: member.get('name'),
      span className: 'cell avatar small round', style: styleAvatar,
        if @props.isEditable and not @isUser member.get '_id'
          i className: classIcon, onClick: onClickAvatar

  renderMembers: ->
    _memberIds = if @beyondMaxNum() then @props._memberIds[..@props.maxNum - 2] else @props._memberIds

    @props.contacts
      .filter (contact) ->
        _memberIds.includes(contact.get('_id'))
      .map @renderMember

  renderMore: ->
    if @beyondMaxNum()
      span className: 'icon icon-more muted cell more'

  renderPlus: ->
    if @props.isEditable
      Tooltip template: lang.getText('invite-members'),
        span className: 'plus', onClick: @onClickPlus,
          i className: 'icon icon-circle-cross'

  render: ->
    classMembersRow = cx 'members-row', 'is-editable': @props.isEditable
    div className: classMembersRow,
      @renderPlus()
      @renderMembers()
      @renderMore()
      @renderRosterManagement()
