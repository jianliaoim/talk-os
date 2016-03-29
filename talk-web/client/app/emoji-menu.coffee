React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

keyboard = require '../util/keyboard'
emojiUtil = require '../util/emoji'

div  = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'emoji-menu'
  mixins: [PureRenderMixin]

  propTypes:
    suggests: T.array.isRequired
    onSelect: T.func.isRequired

  getInitialState: ->
    index: 0

  componentWillReceiveProps: (props) ->
    if props.suggests.length isnt @props.suggests.length
      @setState index: 0

  componentDidMount: ->
    window.addEventListener 'keydown', @onWindowKeydown

  componentWillUnmount: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  # methods

  moveSelectUp: ->
    if @props.suggests.length < 2 then return
    if @state.index is 0
    then @setState index: @props.suggests.length - 1
    else @setState index: (@state.index - 1)

  moveSelectDown: ->
    if @props.suggests.length < 2 then return
    if (@state.index + 1) is @props.suggests.length
    then @setState index: 0
    else @setState index: (@state.index + 1)

  selectCurrent: ->
    emoji = @props.suggests[@state.index]
    @props.onSelect emoji

  # event handlers

  onItemClick: (emoji) ->
    @props.onSelect emoji

  onWindowKeydown: (event) ->
    switch event.keyCode
      when keyboard.up then @moveSelectUp()
      when keyboard.down then @moveSelectDown()
      when keyboard.enter then @selectCurrent()
      when keyboard.tab then @selectCurrent()

  render: ->

    div className: 'emoji-menu menu thin-scroll',
      @props.suggests.map (emoji, index) =>
        onClick = =>
          @onItemClick emoji
        className = cx 'item line',
          'is-active': @state.index is index

        div className: className, onClick: onClick, key: emoji,
          span dangerouslySetInnerHTML: __html: emojiUtil.replace(":#{emoji}:")
          span className: 'short', ":#{emoji}:"
