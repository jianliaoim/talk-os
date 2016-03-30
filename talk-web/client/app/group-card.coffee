React = require 'react'
cx = require 'classnames'
Immutable = require 'immutable'
assign = require 'object-assign'
PureRenderMixin = require 'react-addons-pure-render-mixin'

orders = require '../util/orders'

lang = require '../locales/lang'

groupActions = require '../actions/group'

Permission = require '../module/permission'

MembersRow = React.createFactory require './members-row'
Icon = React.createFactory require '../module/icon'
Avatar = React.createFactory require '../module/avatar'
GroupSettings = React.createFactory require './group-settings'
GroupDetails = React.createFactory require './group-details'

LightDialog = React.createFactory require '../module/light-dialog'
SlimModal = React.createFactory require './slim-modal'

{ div, span, button } = React.DOM

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'group-card'

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    group: T.instanceOf(Immutable.Map).isRequired
    groups: T.instanceOf(Immutable.List).isRequired
    contacts: T.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    modalType: undefined

  onGroupDetailsShow: ->
    @setState modalType: 'details'

  onGroupDetailsClose: ->
    @setState modalType: undefined

  showEditModal: ->
    @setState modalType: 'settings'

  renderGroupDetails: ->
    GroupDetails
      _teamId: @props._teamId
      _userId: @props._userId
      group: @props.group
      contacts: @props.contacts

  renderGroupSettings: ->
    GroupSettings
      _teamId: @props._teamId
      group: @props.group
      groups: @props.groups
      onReturn: @onGroupDetailsShow
      onClose: @onGroupDetailsClose
      contacts: @props.contacts

  renderGroupModal: ->
    modalType = @state.modalType

    props = assign { name: 'group-details', onClose: @onGroupDetailsClose, show: @state.modalType? },
      if modalType is 'details'
        {
          title: @props.group.get('name')
          description: "(#{@props.group.get('_memberIds').size})"
          extra: GroupEditPermission(_teamId: @props._teamId, onEditClick: @showEditModal)
        }
      if modalType is 'settings' then { onBack: @onGroupDetailsShow, name: 'group-settings' }

    SlimModal props,
      switch modalType
        when 'details' then @renderGroupDetails()
        when 'settings' then @renderGroupSettings()

  renderTitle: ->
    div className: 'title flex-horiz',
      div className: 'name flex-fill line',
        @props.group.get('name')
        span className: 'muted', @props.group.get('_memberIds').size
      GroupHandlersetPermission
        _teamId: @props._teamId
        group: @props.group

  renderMembers: ->
    MembersRow
      _teamId: @props._teamId
      _memberIds: @props.group.get('_memberIds')
      contacts: @props.contacts
      maxNum: 10
      onChange: ->

  render: ->
    div className: 'group-card line', onClick: @onGroupDetailsShow,
      @renderTitle()
      @renderMembers()
      @renderGroupModal()

GroupHandlersetClass = React.createClass
  displayName: 'group-handlerset'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    group: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showConfirm: false

  onConfirmClose: ->
    @setState showConfirm: false

  onConfirmShow: (event) ->
    event.stopPropagation()
    @setState showConfirm: true

  onRemoveClick: ->
    groupActions.remove @props.group.get('_id')

  renderConfirm: ->
    LightDialog
      flexible: true
      show: @state.showConfirm
      onCloseClick: @onConfirmClose
      onConfirm: @onRemoveClick
      confirm: l('confirm')
      cancel: l('cancel')
      content: l('team-group-delete-msg')

  render: ->
    div className: 'flex-static actions muted line',
      Icon size: 16, name: 'remove', onClick: @onConfirmShow, className: 'remove'
      @renderConfirm()

GroupEditClass = React.createClass
  displayName: 'group-edit'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    onEditClick: T.func.isRequired

  render: ->
    span className: 'button is-link', onClick: @props.onEditClick, l('edit')

GroupHandlersetPermission = React.createFactory Permission.create(GroupHandlersetClass, Permission.admin)
GroupEditPermission = React.createFactory Permission.create(GroupEditClass, Permission.admin)
