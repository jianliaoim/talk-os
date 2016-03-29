cx = require 'classnames'
React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

deviceActions = require '../actions/device'
notifyActions = require '../actions/notify'
notificationActions = require '../actions/notification'

routerHandler = require '../handlers/router'

lang = require '../locales/lang'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'

refine = require '../util/refine'
search = require '../util/search'
animate = require '../util/animate'
keyboard = require '../util/keyboard'
analytics = require '../util/analytics'

InboxItem = React.createFactory require './inbox-item'

Icon = React.createFactory require '../module/icon'
Keyboard = React.createFactory require '../module/keyboard'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ li, ul, div, input } = React.DOM
T = React.PropTypes

LIMIT = 10
MIN_DIFF = 10
CELL_HEIGHT = 72

module.exports = React.createClass
  displayName: 'inbox-table'
  mixins: [ mixinQuery, mixinSubscribe, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    _channelId: T.string

  getInitialState: ->
    isLoading: false
    isRemoving: false
    isSearching: false
    searchQuery: ''
    selectedNotyIndex: null
    rooms: @getRooms()
    contacts: @getContacts()
    loadStatus: @getLoadStatus()
    notifications: @getNoties()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        rooms: @getRooms()
        contacts: @getContacts()
        loadStatus: @getLoadStatus()
        notifications: @getNoties()

    @_listEl = {}
    @_scrollEl = {}
    @_searchBoxEl = {}

    if @isMounted()
      @_listEl = @refs.list
      @_scrollEl = @refs.scroll
      @_searchBoxEl = @refs.searchBox

      window.addEventListener 'keydown', @onWindowKeyDown
      @simulatedLoadNoties()

  componentWillUnmount: ->
    @_listEl = null
    @_scrollEl = null
    @_searchBoxEl = null

    window.removeEventListener 'keydown', @onWindowKeyDown

  getLoadStatus: ->
    query.inboxLoadStatus recorder.getState(), @props._teamId

  getNoties: ->
    @filterNoties @getNotifications()

  filterNoties: (noties) ->
    noties
    .filterNot refine.isHidden

  searchNoties: (noties) ->
    searchQuery = @state.searchQuery
    targetIds = noties.map (noty) ->
      noty.get '_targetId'

    noties
    .filter (noty) =>
      target = noty.get 'target'
      if not target?
        return false

      type = noty.get 'type'
      switch type
        when 'dms'
          search.forMember target, searchQuery, getAlias: @getContactAlias
        when 'room'
          search.forTopic target, searchQuery
        when 'story'
          search.forStory target, searchQuery
    .concat @searchContacts targetIds
    .concat @searchRooms targetIds

  searchContacts: (targetIds) ->
    searchQuery = @state.searchQuery

    @state.contacts
    .filter (contact) =>
      isMember = search.forMember contact, searchQuery, getAlias: @getContactAlias
      isInclude = targetIds.includes contact.get '_id'
      isMember and not isInclude
    .map (contact) =>
      Immutable.fromJS
        _teamId: @props._teamId
        _targetId: contact.get '_id'
        target:
          _id: contact.get '_id'
          name: contact.get 'name'
          isRobot: contact.get 'isRobot'
          service: contact.get 'service'
          avatarUrl: contact.get 'avatarUrl'
        type: 'dms'
        isFake: true
        isMute: false
        isPinned: false

  searchRooms: (targetIds) ->
    searchQuery = @state.searchQuery

    @state.rooms
    .filter (room) ->
      isRoom = search.forTopic room, searchQuery
      isInclude = targetIds.includes room.get '_id'
      isRoom and not isInclude
    .map (room) =>
      Immutable.fromJS
        _teamId: @props._teamId
        _targetId: room.get '_id'
        target:
          _id: room.get '_id'
          topic: room.get 'topic'
        type: 'room'
        isFake: true
        isMute: false
        isPinned: false

  # Load more notifications method

  loadNoties: (noties) ->
    noties or= @getNoties()

    limit = limit: LIMIT
    if noties.size > 0
      maxUpdatedAt =
        maxUpdatedAt: noties.last().get 'updatedAt'

    data = assign {}, limit, maxUpdatedAt

    fail = =>
      notifyActions.error lang.getText 'api-failed'
      @setState
        isLoading: false

    success = (resp) =>
      @setState isLoading: false

      if resp.length < LIMIT
        deviceActions.updateInboxLoadStatus @props._teamId, true

    afterSetState = =>
      notificationActions
      .read @props._teamId, data, success, fail

    @setState
      isLoading: true
    , afterSetState

  simulatedLoadNoties: ->
    window.requestAnimationFrame =>
      if @_listEl?.clientHeight < @_scrollEl?.clientHeight
        @loadNoties()

  # Handlers for event method

  handleSearchQueryChange: (event) ->
    @setState
      isSearching: event.target.value.trim().length > 0
      searchQuery: event.target.value

  handleClickOnInbox: (event, noty) ->
    success = =>
      if @state.isSearching
        @setState
          searchQuery: ''
          isSearching: false

    @onRoute noty, success
    analytics.switchChatTargetFromRecentList(noty.get('type'))

  handleClickOnInboxRemove: (event, noty) ->
    event.stopPropagation()
    return if @state.isRemoving

    updateNoty = ->
      data =
        isHidden: true
      notificationActions.update noty.get('_id'), data

    if @props._channelId is noty.get '_targetId'
      noties = @getNoties()
      inCollection = (item) -> noty.get('_id') is item.get('_id')
      currentIndex = noties.findIndex inCollection
      return if currentIndex < 0

      success = =>
        @setState
          isRemoving: false

      @setState
        isRemoving: true
      if currentIndex < noties.size - 1
        nextIndex = currentIndex + 1
      else if currentIndex > 0
        nextIndex = currentIndex - 1
      else
        success()
        updateNoty()
        return

      nextNoty = noties.get nextIndex
      @onRoute nextNoty, success

    updateNoty()

  handleClickOnLoader: ->
    @loadNoties()

  handleClickOnSearchBox: ->
    analytics.focusQuickSearch()

  handleKeyboardTrigger: (event, noties) ->
    isActiveElement = document.activeElement is @_searchBoxEl
    return if not isActiveElement

    selectedNotyIndex = @state.selectedNotyIndex

    switch event.which
      when keyboard.enter
        event.preventDefault()
        if selectedNotyIndex? and noties.size > 0
          selectedNoty = noties.get selectedNotyIndex
          success = =>
            @setState
              searchQuery: ''
              isSearching: false
          @onRoute selectedNoty, success
          analytics.switchChatTargetFromQuickSearch(selectedNoty.get('type'))
      when keyboard.down
        event.preventDefault()
        selectedNotyIndex = selectedNotyIndex + 1
        if selectedNotyIndex is noties.size
          selectedNotyIndex = noties.size - 1
        @onScrollDown selectedNotyIndex
      when keyboard.up
        event.preventDefault()
        selectedNotyIndex = selectedNotyIndex - 1
        if selectedNotyIndex < 0
          selectedNotyIndex = 0
        @onScrollUp selectedNotyIndex

    if selectedNotyIndex?
      @setState
        selectedNotyIndex: selectedNotyIndex

  handleKeyboardRegister: ->
    @_scrollEl.scrollTop = 0
    @setState
      selectedNotyIndex: 0

  handleKeyboardUnregister: ->
    @setState
      selectedNotyIndex: null

  handleScroll: ->
    return if not @isMounted()
    return if @state.isSearching
    return if @state.isLoading or @state.loadStatus

    { scrollTop, scrollHeight, clientHeight } = @_scrollEl
    diff = scrollHeight - scrollTop - clientHeight
    if diff <= MIN_DIFF
      @loadNoties()

  # Route method

  onRoute: (noty, cb) ->
    _teamId = noty.get '_teamId'
    _targetId = noty.get '_targetId'
    type = noty.get 'type'
    if type is 'dms' then type = 'chat'
    routerHandler[type] _teamId, _targetId
    cb?()

  onScrollUp: (index) ->
    { clientHeight, scrollTop } = @_scrollEl
    selectedPos = index * CELL_HEIGHT
    if selectedPos < scrollTop
      @_scrollEl.scrollTop = selectedPos

  onScrollDown: (index) ->
    { clientHeight, scrollTop } = @_scrollEl
    selectedPos = (index + 1) * CELL_HEIGHT
    targetPos = selectedPos - clientHeight
    if targetPos > scrollTop
      @_scrollEl.scrollTop = targetPos

  onWindowKeyDown: (event) ->
    if (event.metaKey or event.ctrlKey) and event.which is keyboard.slash
      event.preventDefault()
      @_searchBoxEl.focus()

  render: ->
    noties = @state.notifications
    if @state.isSearching
      noties = @searchNoties noties

    div
      className: 'inbox-table flex-space flex-vert'
      @renderSearchBar noties
      @renderInboxes noties

  # Search box

  renderSearchBar: (noties) ->
    div className: 'inbox-searchbox flex-static',
      div className: 'search-box',
        Icon name: 'search', size: 16
        input
          ref: 'searchBox'
          type: 'text', className: 'input'
          value: @state.searchQuery
          onClick: @handleClickOnSearchBox
          onChange: @handleSearchQueryChange
          onFocus: @handleKeyboardRegister
          onBlur: @handleKeyboardUnregister
          onKeyDown: (event) => @handleKeyboardTrigger(event, noties)
          placeholder: "#{lang.getText('instant-search')} (ctrl + /)"

  # Inbox item renderers

  renderInboxes: (noties) ->
    div
      ref: 'scroll', onScroll: @handleScroll
      className: 'inbox-scroll flex-space thin-scroll'
      ul ref: 'list', noties.map @renderInbox
      @renderLoader()

  renderInbox: (noty, index) ->
    isFake = noty.get 'isFake'
    isPinned = noty.get 'isPinned'
    isRemovable = not (isFake or isPinned)

    li
      key: noty.get '_targetId'
      className: 'list-item'
      InboxItem
        isFake: isFake
        isMute: noty.get 'isMute'
        isActive: @props._channelId is noty.get '_targetId'
        isPinned: isPinned
        isSelected: index is @state.selectedNotyIndex
        isRemovable: isRemovable
        isClearingUnread: query.isClearingUnread(recorder.getState(), noty.get('_teamId'), noty.get('_targetId'))
        onClick: @handleClickOnInbox
        onRemove: @handleClickOnInboxRemove
        unreadNum: noty.get 'unreadNum'
        notification: noty

  # Bottom loader

  renderLoader: ->
    if @state.loadStatus or @state.isSearching
      return null

    div
      onClick: @handleClickOnLoader
      className: 'loader'
      lang.getText if @state.isLoading then 'loading' else 'load-more'
