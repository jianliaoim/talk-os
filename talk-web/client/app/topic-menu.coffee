React = require 'react'
Immutable = require 'immutable'
debounce = require 'debounce'
PureRenderMixin = require 'react-addons-pure-render-mixin'

keyboard = require '../util/keyboard'
dom      = require '../util/dom'
orders   = require '../util/orders'

lang = require '../locales/lang'

TopicName = React.createFactory require '../app/topic-name'

div  = React.createFactory 'div'
span = React.createFactory 'span'
hr   = React.createFactory 'hr'

T = React.PropTypes

# show only 80 of total matches
limit80 = (x) ->
  if x > 80 then 80 else x

module.exports = React.createClass
  displayName: 'topic-menu'
  mixins: [PureRenderMixin]

  propTypes:
    topics:  T.instanceOf(Immutable.List)
    onSelect: T.func.isRequired
    _teamId: T.string.isRequired

  getInitialState: ->
    index: 0

  componentWillReceiveProps: (props) ->
    if props.topics.size isnt @props.topics.size
      @setState index: 0
    if props.topics.size isnt @props.topics.size
      @setState index: 0

  componentDidMount: ->
    @debouncedUpdateScroll = debounce @updateScroll, 50
    window.addEventListener 'keydown', @onWindowKeydown

  componentWillUnmount: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  componentDidUpdate: ->
    root = @refs.root
    @debouncedUpdateScroll(root)

  updateScroll: (root) ->
    eachHeight = 36
    totalHeight = eachHeight * 8
    startY = eachHeight * @state.index
    endY = startY + eachHeight
    top = root.scrollTop

    if (startY < top) or (endY > top + totalHeight)
      y = startY - (totalHeight / 2)
      dom.smoothScrollTo root, 0, y

  # methods

  getTopics: ->
    @props.topics
      .filterNot (topic) ->
        topic.get('isPrivate')
      .sortBy (topic) ->
        topic.get('pinyin')
      .sort orders.isRoomQuit

  getLength: ->
    @getTopics().size

  moveSelectUp: ->
    if @state.index is 0
      @setState index: limit80(@getLength()) - 1
    else
      @setState index: (@state.index - 1)

  moveSelectDown: ->
    if (@state.index + 1) >= limit80(@getLength())
      @setState index: 0
    else
      @setState index: (@state.index + 1)

  selectCurrent: ->
    topic = @getTopics().get(@state.index)
    @props.onSelect topic

  # event handlers

  onItemClick: (topic) ->
    @props.onSelect topic

  onWindowKeydown: (event) ->
    switch event.keyCode
      when keyboard.up then @moveSelectUp()
      when keyboard.down then @moveSelectDown()
      when keyboard.enter then @selectCurrent()
      when keyboard.tab then @selectCurrent()

  onSelect: (index) ->
    @setState {index}

  renderTopics: ->
    @getTopics()
      .map (topic, index) =>
        onClick = =>
          @onItemClick topic
        onMouseEnter = =>
          @onSelect index
        TopicName
          topic: topic
          key: topic.get('_id')
          hover: @state.index is index
          onClick: onClick
          showQuit: true

  render: ->
    div className: 'topic-menu menu thin-scroll', ref: 'root',
      @renderTopics()
