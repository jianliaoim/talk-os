React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

roomActions = require '../actions/room'
storyActions = require '../actions/story'
notifyActions = require '../actions/notify'

routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

mixinUser = require '../mixin/user'
mixinModal = require '../mixin/modal'
mixinSubscribe = require '../mixin/subscribe'

permission = require '../module/permission'

refine = require '../util/refine'
reorder = require '../util/reorder'

RosterList = React.createFactory require './roster-list'
RosterModal = React.createFactory require './roster-modal'
RosterManagement = React.createFactory require './roster-management'

SlimModal = React.createFactory require './slim-modal'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, button, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'channel-member'
  mixins: [ mixinModal, mixinSubscribe, mixinUser, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    _channelType: T.string.isRequired
    channel: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    members =
      switch @props._channelType
        when 'room' then query.membersBy recorder.getState(), @props._teamId, @props.channel.get '_id'
        when 'story' then @props.channel.get 'members'

    members: @filterMembers members

  componentDidMount: ->
    @subscribe recorder, =>
      members =
        switch @props._channelType
          when 'room' then query.membersBy recorder.getState(), @props._teamId, @props.channel.get '_id'
          when 'story' then @props.channel.get 'members'

      @setState
        members: @filterMembers members

  filterMembers: (members) ->
    members
    .sortBy reorder.byPinyin
    .sortBy reorder.byRobot
    .sortBy reorder.byId @getUserId(), true

  handleClickOnButton: ->
    @onOpenModal()

  handleSelectOnMemberList: (target) ->
    routerHandlers.chat @props._teamId, target.get '_id'

  handleSubmitMember: (memberIds) ->
    switch @props._channelType
      when 'room' then @onSubmitRoomMember memberIds
      when 'story' then @onSubmitStoryMember memberIds

  onExtractData: (prevIds, nextIds) ->
    if not prevIds.toSet().equals(nextIds.toSet())
      data = Immutable.Map()
      addMembers = Immutable.List()
      removeMembers = Immutable.List()

      nextIds.forEach (nextId) ->
        if not prevIds.includes nextId
          addMembers = addMembers.push nextId

      prevIds.forEach (prevId) ->
        if not nextIds.includes prevId
          removeMembers = removeMembers.push prevId

      if addMembers.size > 0
        data = data.set 'addMembers', addMembers

      if removeMembers.size > 0
        data = data.set 'removeMembers', removeMembers

      return data

    return false

  onSubmitRoomMember: (memberIds) ->
    prevIds = @props.channel.get '_memberIds'
    nextIds = memberIds

    data = @onExtractData prevIds, nextIds
    if data
      channelId = @props.channel.get '_id'
      roomActions.roomUpdate channelId, data.toJS()

  onSubmitStoryMember: (memberIds) ->
    prevIds = @props.channel.get '_memberIds'
    nextIds = memberIds

    data = @onExtractData prevIds, nextIds
    if data
      channelId = @props.channel.get '_id'
      storyActions.update channelId, data.toJS()

  ###
   * Renderer
  ###

  renderList: ->
    RosterList
      _teamId: @props._teamId
      type: 'contact'
      rosters: @state.members
      onSelect: @handleSelectOnMemberList

  renderModal: ->
    # title not correct

    SlimModal
      name: 'channel-member'
      title: lang.getText('manage-member')
      show: @state.showModal
      showClose: false
      onClose: @onCloseModal
      RosterModalPermission
        _teamId: @props._teamId
        _creatorId: @props.channel.get '_creatorId'
        onClose: @onCloseModal
        onSubmit: @handleSubmitMember
        selectedContacts: @props.channel.get '_memberIds'

  render: ->
    isRoom = @props._channelType is 'room'
    isPrivate = @props.channel.get 'isPrivate'
    isGeneral = @props.channel.get 'isGeneral'
    isPublic = isRoom and not isPrivate

    div className: 'channel-member',
      @renderList()
      ButtonPermission
        _teamId: @props._teamId
        _creatorId: @props.channel.get '_creatorId'
        onClick: @handleClickOnButton
        isPublic: isPublic
        isGeneral: isGeneral
      @renderModal()

###
 * Permission Factory,
 * create permission class within same roles.
###

PermissionFactory = (ReactClass) ->
  React.createFactory permission.create ReactClass,
    permission.member
    permission.mode.propogate

ButtonPermission = PermissionFactory React.createClass
  displayName: 'button-permission'

  propTypes:
    onClick: T.func.isRequired
    isPublic: T.bool
    isGeneral: T.bool

  handleClick: ->
    @props.onClick()

  render: ->
    if @props.isGeneral
      return null

    button
      onClick: @handleClick
      className: 'action'
      if @props.role in permission.superRole
        lang.getText 'manage-member'
      else
        lang.getText 'invite-members'

RosterModalPermission = PermissionFactory React.createClass
  displayName: 'roster-modal-permission'

  propTypes:
    onClose: T.func.isRequired
    onSubmit: T.func.isRequired
    selectedContacts: T.instanceOf(Immutable.List).isRequired

  render: ->
    isSuperRole = @props.role in permission.superRole

    RosterManagement
      _teamId: @props._teamId
      onClose: @props.onClose
      onSubmit: @props.onSubmit
      isRemovable: isSuperRole
      selectedContacts: @props.selectedContacts
