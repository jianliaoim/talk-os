cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

colors = require '../util/colors'
dom = require '../util/dom'

Icon = React.createFactory require '../module/icon'
TopicName = React.createFactory require '../app/topic-name'
ContactName = React.createFactory require '../app/contact-name'

{ p, div, span} = React.DOM

T = React.PropTypes
l = lang.getText

storyColor =
  topic: '#4fc3f7'
  file:  '#009688'
  link:  '#9ccc65'

storyIcon =
  topic: 'sharp'
  file:  'paperclip'
  link:  'link'

module.exports = React.createClass
  displayName: 'search-suggest'
  mixins: [PureRenderMixin]

  propTypes:
    _teamId:          T.string.isRequired
    cursor:           T.number.isRequired
    contacts:         T.instanceOf(Immutable.List)
    stories:          T.instanceOf(Immutable.List)
    rooms:            T.instanceOf(Immutable.List)
    query:            T.string.isRequired
    onIndexClick:     T.func.isRequired
    searchMode:       T.bool

  componentDidUpdate: ->
    @handleScroll()

  # methods

  getDefaultProps: ->
    searchMode: true
    contacts: Immutable.List()
    rooms: Immutable.List()
    stories: Immutable.List()

  triggerIndex: (index) ->
    @props.onIndexClick index

  # events

  onSearchAllClick: ->
    @triggerIndex 0

  onSearchStoryClick: ->
    @triggerIndex 1

  handleScroll: ->
    unless @refs.scroll?
      return
    each = 34
    scrollEl = @refs.scroll

    totalHeight = scrollEl.clientHeight
    top = scrollEl.scrollTop

    current = @props.cursor

    startY = current * each

    if ((startY - top) < 0) or ((startY + each) - top > totalHeight)
      y = startY - totalHeight / 2
      dom.smoothScrollTo scrollEl, 0, y

  # renderers

  renderRooms: ->
    spec = if @props.searchMode then 2 else 0
    @props.rooms.map (room, index) =>
      cursor = index + spec + @props.contacts.size
      onClick = =>
        @triggerIndex cursor

      TopicName
        key: room.get('_id')
        topic: room
        hover: cursor is @props.cursor
        colorizePlace: 'background'
        showUnread: false
        showPurpose: false
        showGuest: false
        onClick: onClick

  renderContacts: ->
    spec = if @props.searchMode then 2 else 0
    @props.contacts.map (contact, index) =>
      cursor = index + spec
      onClick = =>
        @triggerIndex cursor

      ContactName
        key: contact.get('_id')
        contact: contact
        _teamId: @props._teamId
        hover: cursor is @props.cursor
        showUnread: false
        showEmail: false
        onClick: onClick
        isQuit: contact.get('isQuit')

  renderStories: ->
    spec = if @props.searchMode then 2 else 0
    @props.stories.map (story, index) =>
      cursor = index + spec + @props.contacts.size + @props.rooms.size
      category = story.get('category')
      thumnailStyle =
        backgroundColor: storyColor[category]
      cxStoryName = cx 'banner', 'line', 'story-name', 'is-active': cursor is @props.cursor
      cxAvatar = cx 'ti', "ti-#{ storyIcon[category] }", 'is-leading'

      onClick = =>
        @triggerIndex cursor

      div className: cxStoryName, key: story.get('_id'), onClick: onClick,
        span className: cxAvatar, style: thumnailStyle
        span className: 'name short', story.get('title')

  render: ->
    classAll = cx 'builtin', 'is-active': (@props.cursor is 0)
    classStory = cx 'builtin', 'is-active': (@props.cursor is 1)

    searchAll = lang.getText('search-%s-in-all-talk').replace('%s', @props.query)
    searchStory = lang.getText('search-%s-in-story').replace('%s', @props.query)

    div className: 'search-suggest', ref: 'scroll',
      if @props.searchMode
        div className: 'spec',
          div className: classAll, onClick: @onSearchAllClick,
            Icon name: 'search', size: 18
            span className: 'text muted', searchAll
          div className: classStory, onClick: @onSearchStoryClick,
            Icon name: 'search', size: 18
            span className: 'text muted', searchStory
      #contact
      if @props.contacts.size > 0
        div className: 'group',
          if @props.searchMode
            div className: 'slim-bar', l('member')
          @renderContacts()
      #room
      if @props.rooms.size > 0
        div className: 'group',
          if @props.searchMode
            div className: 'slim-bar', l('room')
          @renderRooms()
      #story
      if @props.stories.size > 0
        div className: 'group',
          if @props.searchMode
            div className: 'slim-bar', 'story'
          @renderStories()
      if not @props.searchMode and ( @props.contacts.size < 3 and @props.contacts.size < 3 )
        @props.children
