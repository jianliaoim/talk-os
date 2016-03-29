React = require 'react'
Immutable = require 'immutable'
cx = require 'classnames'

detect = require '../util/detect'
search = require '../util/search'
detect = require '../util/detect'
orders = require '../util/orders'
analytics = require '../util/analytics'

lang = require '../locales/lang'

roomActions = require '../actions/room'
Permission = require '../module/permission'

routerHandlers = require '../handlers/router'

RoomItem = React.createFactory require './room-item'
TopicProfile = React.createFactory require './topic-profile'
SearchBox = React.createFactory require('react-lite-misc').SearchBox
SlimModal = React.createFactory require './slim-modal'

{ a, p, div, span, input, button, textarea } = React.DOM

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'panel-room'

  propTypes:
    _teamId: T.string.isRequired
    rooms: T.instanceOf(Immutable.List).isRequired
    archivedRooms: T.instanceOf(Immutable.List).isRequired
    onClose: T.func

  getDefaultProps: ->
    invitations: Immutable.List()

  getInitialState: ->
    showCreate: false
    value: ''
    isPrivate: false

  filterList: (list) ->
    search.forTopics list, @state.value
    .sort orders.isGeneral

  onCreateShow: ->
    @setState showCreate: true

  onCreateClose: ->
    @setState showCreate: false

  onAddClick: ->
    @setState showForm: (not @state.showForm)

  onChange: (value) ->
    @setState { value }

  onItemClick: (room) ->
    analytics.enterRoom()
    routerHandlers.room @props._teamId, room.get('_id'), {}, @props.onClose

  onTopicSave: (data, successCB, errorCB) ->
    data._teamId = @props._teamId
    unless data.color then data.color = 'blue'
    roomActions.roomCreate data
    , (resp) =>
      @onItemClick Immutable.fromJS(resp)
      successCB()
    , ->
      errorCB()

  renderHeader: ->
    div className: 'header flex-horiz line flex-vcenter',
      SearchBox
        value: @state.value
        onChange: @onChange
        locale: lang.getText('search-topics')
        autoFocus: not detect.isIPad()
      span className: 'muted or flex-static', lang.getText('or')
      button className: 'button flex-static', onClick: @onCreateShow,lang.getText('create-a-topic')

  getJoinedRooms: ->
    @props.rooms.filter (room) -> detect.inChannel(room)

  getQuittedRooms: ->
    @props.rooms.filterNot (room) -> detect.inChannel(room)

  renderRooms: (type) ->
    switch type
      when 'joined'
        filteredList = @filterList(@getJoinedRooms())
        info = l('topic-joined-num')
      when 'archived'
        filteredList = @filterList(@props.archivedRooms)
        info = l('topic-archived-num')
      else
        filteredList = @filterList(@getQuittedRooms())
        info = l('topic-quit-num')

    if filteredList.size > 0
      div className: 'item-list room-list',
        p className: 'info muted', info.replace('{{num}}', filteredList.size)
        filteredList.map (room) =>
          onItemClick = =>
            @onItemClick room

          RoomItem
            key: room.get('_id')
            _teamId: @props._teamId
            room: room
            isArchived: type is 'archived'
            onClick: onItemClick
            showAction: type is 'archived'

  renderCreate: ->
    SlimModal
      name: 'topic-profiles'
      title: l('topic-create')
      onClose: @onCreateClose
      show: @state.showCreate
      TopicProfile
        _teamId: @props._teamId
        topic: Immutable.fromJS({name: '', purpose: '', color: 'blue'})
        hasPermission: true
        saveConfigs: @onTopicSave

  render: ->
    div className: 'panel-chat panel-room',
      @renderHeader()
      @renderRooms('joined')
      @renderRooms()
      @renderRooms('archived')
      @renderCreate()
