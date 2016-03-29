React = require 'react'
keycode = require 'keycode'
classnames = require 'classnames'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'

search = require '../util/search'
detect = require '../util/detect'
dom = require '../util/dom'

TopicCorrection = React.createFactory require './topic-correction'
LiteDropdown = React.createFactory require 'react-lite-dropdown'

hr = React.createFactory 'hr'
div = React.createFactory 'div'
input = React.createFactory 'input'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'filter-topic'
  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _roomId: T.string
    isDirectMessage: T.bool
    onChange: T.func.isRequired

  getDefaultProps: ->
    isDirectMessage: false

  getInitialState: ->
    query: ''
    showMenu: false
    index: 0

  componentDidMount: ->
    @setState index: @getDefaultIndex()

  componentDidUpdate: ->
    @handScroll()

  # user methods

  getDefaultIndex: ->
    if @props._roomId
      (@fitlerTopics().findIndex (topic) => topic.get('_id') is @props._roomId) + 2
    else if @props.isDirectMessage
      1
    else
      0

  fitlerTopics: ->
    topics = query.topicsBy(recorder.getState(), @props._teamId) or Immutable.List()
    topics = topics.filter (topic) -> detect.inChannel(topic)
    topics = search.forTopics topics, @state.query

  getListLength: ->
    length = @fitlerTopics().size
    if @state.query.length is 0
      length += 2
    length

  moveUp: ->
    if @state.index is 0
      @setState index: (@getListLength() - 1)
    else
      @setState index: @state.index - 1

  moveDown: ->
    if (@state.index + 1) >= @getListLength()
      @setState index: 0
    else
      @setState index: @state.index + 1

  selectCurrent: ->
    topics = @fitlerTopics()
    if (@state.query.length is 0)
      switch @state.index
        when 0
          @props.onChange undefined, false
        when 1
          @props.onChange undefined, true
        else
          current = @state.index - 2
          topic = topics.get('current')
          @props.onChange topic.get('_id'), false
    else
      topics = @fitlerTopics()
      topic = topics.get(@state.index)
      @props.onChange topic.get('_id')
    @onMenuToggle()

  handScroll: ->
    unless @refs.scroll?
      return
    each = 40
    hrHeight = 11
    scrollEl = @refs.scroll

    totalHeight = scrollEl.clientHeight
    top = scrollEl.scrollTop

    current = @state.index

    startY = current * each
    if (@state.query.length > 0) and (current >= 2)
      startY += hrHeight

    if ((startY - top) < 0) or ((startY + each) - top > totalHeight)
      y = startY - totalHeight / 2
      dom.smoothScrollTo scrollEl, 0, y

  # events

  onInputClick: (event) ->
    event.stopPropagation()

  onTopicChange: (topic) ->
    @props.onChange topic

  onQueryChange: (event) ->
    @setState query: event.target.value.trim(), index: 0

  onItemClick: (topic, index) ->
    @props.onChange topic.get('_id'), false
    if @state.query.length > 0
      @setState index: index
    else
      @setState index: index + 2

  onAllClick: ->
    @props.onChange undefined, false
    @setState index: 0

  onPrivateClick: ->
    @props.onChange undefined, true
    @setState index: 1

  onMenuToggle: (event) ->
    event?.preventDefault()
    index = @getDefaultIndex()
    @setState
      index: index
      showMenu: not @state.showMenu

  onKeyDown: (event) ->
    switch keycode(event.keyCode)
      when 'up' then @moveUp()
      when 'down' then @moveDown()
      when 'enter' then @selectCurrent()

  renderTopics: ->
    topics = @fitlerTopics()
    if @state.query.length is 0
      current = @state.index - 2
    else
      current = @state.index

    topics.map (topic, index) =>
      onClick = => @onItemClick topic, index
      className = classnames 'item', 'topic',
        'is-active': (index is current)
      div key: topic.get('_id'), className: className, onClick: onClick,
        TopicCorrection {topic}

  render: ->
    topics = query.topicsBy(recorder.getState(), @props._teamId) or Immutable.List()
    topic = topics.find (topic) =>
      topic.get('_id') is @props._roomId
    if @props.isDirectMessage
      defaultText = lang.getText('conversation')
    else
      defaultText = lang.getText('all-positions')

    itemAllClass = classnames 'item',
      'is-active': (@state.query.length is 0) and (@state.index is 0)
    itemPrivateClass = classnames 'item',
      'is-active': (@state.query.length is 0) and (@state.index is 1)

    if topic?.get('isGeneral')
      name = lang.getText 'room-general'
    else
      name = topic?.get('topic')

    LiteDropdown
      displayText: name or undefined
      defaultText: defaultText
      name: 'filter-topic'
      show: @state.showMenu
      onToggle: @onMenuToggle
      input
        className: 'query', value: @state.query, autoFocus: true, type: 'text'
        onChange: @onQueryChange, onClick: @onInputClick, onKeyDown: @onKeyDown
      div ref: 'scroll', className: 'results scroll thin-scroll',
        if @state.query.length is 0
          div null,
            div className: itemAllClass, onClick: @onAllClick, lang.getText('all-positions')
            div className: itemPrivateClass, onClick: @onPrivateClick, lang.getText('conversation')
            hr className: 'divider'
        @renderTopics()
