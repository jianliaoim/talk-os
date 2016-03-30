React = require 'react'
Immutable = require 'immutable'
cx = require 'classnames'
recorder = require 'actions-recorder'

query = require '../query'

roomActions = require '../actions/room'

Permission = require '../module/permission'

mixinSubscribe = require '../mixin/subscribe'

detect = require '../util/detect'
search = require '../util/search'
colors = require '../util/colors'
time = require '../util/time'

lang = require '../locales/lang'

TopicCorrection = React.createFactory require './topic-correction'
Avatar = React.createFactory require '../module/avatar'

LightDialog = React.createFactory require '../module/light-dialog'

{ div, span, button } = React.DOM

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'room-item'

  mixins: [ mixinSubscribe ]

  propTypes:
    _teamId: T.string
    room: T.instanceOf(Immutable.Map).isRequired
    isArchived: T.bool
    showAction: T.bool
    onChange: T.func

  getDefaultProps: ->
    isArchived: false
    showAction: true

  getInitialState: ->
    contacts: @getContacts()
    alias: @getAlias()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        contacts: @getContacts()
        alias: @getAlias()

  getContacts: ->
    query.contactsBy(recorder.getState(), @props._teamId)

  getAlias: ->
    query.contactPrefsBy(recorder.getState(), @props._teamId, @props.room.get('_creatorId'))?.get('alias')

  onClick: ->
    @props.onClick?()

  renderAvatar: ->
    Avatar
      size: 'normal'
      shape: 'round'
      className: 'ti ti-sharp round flex-static'

  renderBody: ->
    div className: 'body flex-vert flex-fill',
      TopicCorrection topic: @props.room
      span className: 'desc muted text-overflow', @getDescription()

  getDescription: ->
    creator = @state.contacts.find (contact) =>
      contact.get('_id') is @props.room.get('_creatorId')
    name = @state.alias or creator?.get('name') or lang.getText('left-member')

    purpose = @props.room.get('purpose')
    createInfo = lang.getText('team-rooms-description')
    .replace '{{time}}', time.calendar(@props.room.get('createdAt'))
    .replace '{{name}}', name

    purpose or createInfo

  renderRoom: ->
    _roomId = @props.room.get('_id')
    cxItem = cx 'room-item', 'flex-horiz', 'flex-vcenter', 'line'
    div className: cxItem, key: _roomId, onClick: @onClick,
      @renderAvatar()
      div className: 'content flex-horiz flex-fill flex-vcenter line',
        @renderBody()
        div className: 'flex-static line muted flex-horiz vert-vcenter',
          span className: 'ti ti-user'
          @props.room.get('memberCount')
      if @props.showAction
        unless @props.room.get('isGeneral')
          if @props.room.get('isArchived')
            ArchivedRoomItemsHandlersetPermission
              _teamId: @props._teamId
              room: @props.room

  render: ->
    @renderRoom()

ArchivedRoomItemHandlersetClass = React.createClass
  displayName: 'archived-room-item-handlerset'

  propTypes:
    _teamId: T.string.isRequired
    room: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showConfirm: false

  onRecover: ->
    roomActions.roomArchive @props.room.get('_id'), false

  onConfirmShow: ->
    @setState showConfirm: true

  onRemoveClick: ->
    # 权限
    roomActions.roomRemove @props.room.get('_id')

  onCloseConfirm: ->
    @setState showConfirm: false

  renderConfirm: ->
    LightDialog
      flexible: true
      show: @state.showConfirm
      onCloseClick: @onCloseConfirm
      onConfirm: @onRemoveClick
      confirm: l('confirm')
      cancel: l('cancel')
      content: l('confirm-delete-topic')

  render: ->
    div className: 'archived-room-item-handlerset handlerset flex-static line',
      button className: 'button is-primary is-small', onClick: @onRecover, '还原'
      # button className: 'button is-danger is-small', onClick: @onConfirmShow, '删除'
      @renderConfirm()

ArchivedRoomItemsHandlersetPermission = React.createFactory Permission.create(ArchivedRoomItemHandlersetClass, Permission.admin)
