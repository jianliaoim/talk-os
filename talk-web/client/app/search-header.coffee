React = require 'react'
Immutable = require 'immutable'
query = require '../query'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'

lang      = require '../locales/lang'
keyboard  = require '../util/keyboard'
time      = require '../util/time'
util      = require '../util/util'
search    = require '../util/search'
detect    = require '../util/detect'
analytics = require '../util/analytics'
routerHandlers = require '../handlers/router'


div   = React.createFactory 'div'
span  = React.createFactory 'span'
input = React.createFactory 'input'

Icon = React.createFactory require '../module/icon'
SearchSuggest = React.createFactory require './search-suggest'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'search-header'
  mixins: [mixinSubscribe, PureRenderMixin, mixinQuery]

  propTypes:
    _teamId: T.string.isRequired
    onSearch: T.func.isRequired
    onSearchStory: T.func.isRequired

  getDefaultProps: ->
    suggest: true

  getInitialState: ->
    contacts: @getContacts()
    topics: @getRooms()
    leftContacts: @getLeftContacts()
    rooms: Immutable.List()
    resultRooms: Immutable.List()
    resultContacts: Immutable.List()
    cursor: 0
    query: ''
    focus: false
    suggestClosed: false

  componentDidMount: ->
    @_inputEl = @refs.input
    @_rootEl = @refs.root

    window.addEventListener 'keydown', @onWindowKeydown
    @subscribe recorder, =>
      @setState
        contacts: @getContacts()
        topics: @getRooms()
        leftContacts: @getLeftContacts()

  componentWillUnmount: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  # methods

  getAllContacts: ->
    _userId = query.userId(recorder.getState())
    @state.contacts
    .filterNot (member) -> member.get('isGuest') or member.get('_id') is _userId
    .concat @state.leftContacts

  handleSlash: (event) ->
    if event.target.tagName in ['INPUT', 'TEXTAREA', 'SELECT']
      if event.metaKey or event.ctrlKey
        event.preventDefault()
        @_inputEl.select()
    else
      event.preventDefault()
      @_inputEl.select()

  filterRooms: (searchQuery) ->
    results = search.forTopics(@state.topics, searchQuery)
    .filter (room) -> detect.inChannel(room)

  filterContacts: (searchQuery) ->
    results = search.forMembers @getAllContacts(), searchQuery, getAlias: @getContactAlias
    .sort (a, b) ->
      switch
        when (not a.get('isQuit')) and b.get('isQuit') then -1
        when a.get('isQuit') and (not b.get('isQuit')) then 1
        else 0

  chooseCurrent: ->
    if @state.cursor is 0
      @searchInAll()
    else if @state.cursor is 1
      @searchInStories()
    else
      @navigateByIndex @state.cursor

  navigateByIndex: (index) ->
    cursor = index - 2
    if index is 0
      @searchInAll()
    else if index is 1
      @searchInStories()
    else if cursor < @state.resultContacts.size
      hit = @state.resultContacts.get(cursor)
      routerHandlers.chat @props._teamId, hit.get('_id')
    else
      cursor -= @state.resultContacts.size
      hit = @state.resultRooms.get(cursor)
      routerHandlers.room @props._teamId, hit.get('_id')
    analytics.switchChatTargetFromSearch()

  getBaseAreaLeft: ->
    if @_rootEl?
      @_rootEl.getBoundingClientRect().left
    else 0

  choosePrevious: ->
    size = @state.resultRooms.size + @state.resultContacts.size
    if @state.cursor > 0
      @setState cursor: (@state.cursor - 1)
    else
      @setState cursor: size + 1

  chooseNext: ->
    size = @state.resultRooms.size + @state.resultContacts.size
    if @state.cursor > size
      @setState cursor: 0
    else
      @setState cursor: (@state.cursor + 1)

  searchInAll: ->
    @props.onSearch @state.query
    @setState
      suggestClosed: true

  searchInStories: ->
    @props.onSearchStory @state.query
    @setState
      suggestClosed: true

  # events

  onWindowKeydown: (event) ->
    if (event.keyCode is keyboard.slash)
      @handleSlash event

  onChange: (event) ->
    searchQuery = event.target.value.trim()
    resultRooms = @filterRooms(searchQuery)[..4]
    resultContacts = @filterContacts(searchQuery)[..4]
    @setState {query: searchQuery, resultRooms, resultContacts, cursor: 0, suggestClosed: false}

  onKeyDown: (event) ->
    switch event.keyCode
      when keyboard.up
        event.preventDefault()
        @choosePrevious()
      when keyboard.down
        event.preventDefault()
        @chooseNext()
      when keyboard.enter
        event.preventDefault()
        event.target.select()
        @chooseCurrent()
        @setState
          resultQuery: @state.query

  onFocus: ->
    @setState focus: true

  onBlur: ->
    # tricky part, without delay, dom is removed, event not captured
    time.delay 200, =>
      if @isMounted()
        @setState focus: false

  onIndexClick: (index) ->
    @navigateByIndex index

  renderSuggest: ->
    div className: 'suggest-wrap',
      SearchSuggest
        _teamId: @props._teamId
        cursor: @state.cursor
        contacts: @state.resultContacts
        rooms: @state.resultRooms
        query: @state.query
        onIndexClick: @onIndexClick

  render: ->
    div ref: 'root', className: 'search-header',
      div className: 'form-control flex-horiz flex-vcenter',
        input
          onKeyDown: @onKeyDown
          onChange: @onChange
          onFocus: @onFocus
          onBlur: @onBlur
          ref: 'input'
          className: 'input'
          placeholder: lang.getText('search-with-keywords')
          autoFocus: not detect.isIPad()
        Icon name: 'search', size: 18, className: 'flex-static'
      if (not @state.suggestClosed) and (@state.query.length > 0) and @state.focus
        @renderSuggest()
