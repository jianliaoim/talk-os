React = require 'react'
cx = require 'classnames'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

groupActions = require '../actions/group'

orders = require '../util/orders'

Permission = require '../module/permission'

Icon = React.createFactory require '../module/icon'
GroupCard = React.createFactory require './group-card'
GroupSettings = React.createFactory require './group-settings'
SlimModal = React.createFactory require './slim-modal'

{ div, p, span, input } = React.DOM

T = React.PropTypes


module.exports = React.createClass
  displayName: 'group-board'

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    groups: T.instanceOf(Immutable.List).isRequired
    contacts: T.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    showCreateModal: false

  onCreateClick: ->
    @setState showCreateModal: true

  onCreateClose: ->
    @setState showCreateModal: false

  renderCreateModal: ->
    SlimModal
      name: 'group-settings'
      title: lang.getText('team-group-create')
      onClose: @onCreateClose
      show: @state.showCreateModal
      GroupSettings
        _teamId: @props._teamId
        groups: @props.groups
        onClose: @onCreateClose
        contacts: @props.contacts

  renderGroups: ->
    div className: 'group-list flex-fill flex-stretch thin-scroll',
      if @props.groups.size > 0
        @props.groups
        .sort orders.byReverseDate
        .map (group) =>
          GroupCard
            key: group.get('_id')
            group: group
            groups: @props.groups
            _teamId: @props._teamId
            _userId: @props._userId
            contacts: @props.contacts
      else
        p className: 'muted placeholder', lang.getText('team-group-placeholder')

  renderCreate: ->
    GroupCreatePermission
      _teamId: @props._teamId
      onCreateClick: @onCreateClick

  render: ->
    div className: 'group-board flex-vert flex-fill flex-space',
      @renderGroups()
      @renderCreate()
      @renderCreateModal()

GroupCreateClass = React.createClass
  displayName: 'group-create'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    onCreateClick: T.func.isRequired

  render: ->
    div className: 'footer group-create flex-horiz flex-static',
      div className: 'button', onClick: @props.onCreateClick,
        Icon size: 20, name: 'plus'
        span className: 'text', lang.getText('team-group-create')

GroupCreatePermission = React.createFactory Permission.create(GroupCreateClass, Permission.admin)
