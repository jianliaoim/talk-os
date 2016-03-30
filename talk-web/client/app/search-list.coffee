React = require 'react'
Immutable = require 'immutable'
keycode = require 'keycode'
PureRenderMixin = require 'react-addons-pure-render-mixin'

dom = require '../util/dom'
search = require '../util/search'
mixinQuery = require '../mixin/query'

Icon = React.createFactory require '../module/icon'
ContactName = React.createFactory require './contact-name'
TopicName = React.createFactory require './topic-name'
GroupItem = React.createFactory require './group-item'
SearchBox = React.createFactory require('react-lite-misc').SearchBox

{ div, span, input } = React.DOM

T = React.PropTypes

ITEM_HEIGHT = 40

module.exports = React.createClass
  displayName: 'search-list'

  mixins: [ mixinQuery, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    contacts: T.instanceOf(Immutable.List)
    groups: T.instanceOf(Immutable.List)
    rooms: T.instanceOf(Immutable.List)
    selectedGroups: T.instanceOf(Immutable.List)
    selectedContacts: T.instanceOf(Immutable.List)
    selectedRooms: T.instanceOf(Immutable.List)
    onContactClick: T.func
    onGroupClick: T.func
    onRoomClick: T.func
    title: T.string
    locale: T.string
    autoFocus: T.bool
    placeholder: T.string

  getDefaultProps: ->
    contacts: Immutable.List()
    groups: Immutable.List()
    rooms: Immutable.List()
    selectedGroups: Immutable.List()
    selectedContacts: Immutable.List()
    selectedRooms: Immutable.List()
    autoFocus: true
    locale: ''
    placeholder: ''

  getInitialState: ->
    query: ''
    cursor: 0
    filteredGroups: @props.groups
    filteredRooms: @props.rooms
    filteredContacts: @props.contacts

  componentDidMount: ->
    @inputEl = @refs.input
    @_maxHeight = ITEM_HEIGHT * ( @props.contacts.size + @props.groups.size + @props.rooms.size )

  componentDidUpdate: ->
    @handleScroll()

  hasNoResult: ->
    @state.filteredGroups.size + @state.filteredRooms.size + @state.filteredContacts.size is 0

  handleScroll: ->
    return unless @refs.scroll
    scrollEl = @refs.scroll
    totalHeight = scrollEl.clientHeight
    top = scrollEl.scrollTop

    startY = @state.cursor * ITEM_HEIGHT

    if ((startY - top) < 0) or ((startY + ITEM_HEIGHT) - top > totalHeight)
      y = startY - totalHeight / 2
      dom.smoothScrollTo scrollEl, 0, y

  moveUp: ->
    cursor = (@state.cursor and ( @state.cursor - 1 )) or (@getListLength() - 1)
    @setState { cursor }

  moveDown: ->
    cursor = (@state.cursor < @getListLength() - 1 and ( @state.cursor + 1 )) or 0
    @setState { cursor }

  selectCurrent: ->
    return if @hasNoResult()

    groupIndex = @state.cursor
    roomIndex = @state.cursor - @state.filteredGroups.size
    contactIndex = @state.cursor - @state.filteredGroups.size - @state.filteredRooms.size

    if contactIndex >= 0
      contact = @state.filteredContacts.get contactIndex
      @props.onContactClick(contact)
    else if roomIndex >= 0
      room = @state.filteredRooms.get roomIndex
      @props.onRoomClick(room)
    else if groupIndex >= 0
      group = @state.filteredGroups.get groupIndex
      @props.onGroupClick(group)

  filterList: (list, keyword, isContact) ->
    opt = getAlias: if isContact then @getContactAlias
    search.inKeyword list, keyword, opt

  getListLength: ->
    @state.filteredGroups.size + @state.filteredRooms.size + @state.filteredContacts.size

  onChange: (event) ->
    query = event.target.value
    @setState
      query: query
      filteredGroups: @filterList(@props.groups, query)
      filteredRooms: @filterList(@props.rooms, query)
      filteredContacts: @filterList(@props.contacts, query, true)

  onKeyDown: (event) ->
    switch (keycode event.keyCode)
      when 'up' then @moveUp()
      when 'down' then @moveDown()
      when 'enter' then @selectCurrent()

  renderSearch: ->
    div className: 'search-input flex-horiz flex-vcenter',
      Icon name: 'search', size: 18, className: 'flex-static'
      input
        ref: 'input', type: 'text', className: 'input flex-fill', placeholder: @props.locale, value: @state.query,
        onChange: @onChange, onKeyDown: @onKeyDown, autoFocus: @props.autoFocus

  renderPlaceholder: ->
    if @hasNoResult()
      span className: 'placeholder muted', @props.placeholder

  renderGroups: ->
    @state.filteredGroups.map (group, index) =>
      onGroupClick = =>
        @props.onGroupClick group
        @setState
          cursor: index
          , => @inputEl.focus()

      GroupItem
        key: group.get('_id')
        group: group
        showSelect: true
        hover: index is @state.cursor
        isSelected: @props.selectedGroups.contains group.get('_id')
        onClick: onGroupClick

  renderRooms: ->
    @state.filteredRooms.map (topic, index) =>
      onRoomClick = =>
        @props.onRoomClick topic
        @setState
          cursor: index + @state.filteredGroups.size
          , => @inputEl.focus()

      TopicName
        key: topic.get('_id')
        topic: topic
        hover: index is (@state.cursor - @state.filteredGroups.size)
        active: @props.selectedRooms.contains topic.get('_id')
        onClick: onRoomClick

  renderContacts: ->
    @state.filteredContacts.map (contact, index) =>
      onContactClick = =>
        @props.onContactClick contact
        @setState
          cursor: index + @state.filteredGroups.size + @state.filteredRooms.size
          , => @inputEl.focus()

      ContactName
        key: contact.get('_id')
        _teamId: @props._teamId
        contact: contact
        hover: index is (@state.cursor - @state.filteredGroups.size - @state.filteredRooms.size)
        active: @props.selectedContacts.contains contact.get('_id')
        onClick: onContactClick

  render: ->
    listStyle =
      height: @_maxHeight or 'auto'

    div className: 'search-list flex-vert',
      div className: 'search flex-static',
        if @props.title? then span className: 'search-list-title', @props.title
        @renderSearch()
      div className: 'list flex-fill thin-scroll', style: listStyle, ref: 'scroll',
        @renderPlaceholder()
        @renderRooms()
        @renderGroups()
        @renderContacts()
