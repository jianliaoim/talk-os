React = require 'react'

mixinLayered = require '../mixin/layered'

{ a, div, span, noscript } = React.DOM
T = React.PropTypes

PopoverMenu = React.createFactory React.createClass
  displayName: 'light-popover-menu'

  propTypes:
  # accepts children
    onClose: T.func.isRequired
    style: T.object.isRequired
    decorator: T.string.isRequired

  componentDidMount: ->
    window.addEventListener 'click', @onWindowClick
    window.addEventListener 'popouts', @onWindowClick

  componentWillUnmount: ->
    window.removeEventListener 'click', @onWindowClick
    window.removeEventListener 'popouts', @onWindowClick

  onWindowClick: ->
    @props.onClose()

  onClick: (event) ->
    event.stopPropagation()

  render: ->
    div className: "light-popover #{@props.decorator}", style: @props.style, onClick: @onClick,
      @props.children

module.exports = React.createClass
  displayName: 'light-popover'
  mixins: [mixinLayered]

  propTypes:
  # this component accepts children
    title:              T.string
    name:               T.string
    onPopoverClose:     T.func
    positionAlgorithm:  T.func # could be customized
    baseArea:           T.object.isRequired # top, right, down, left
    showClose:          T.bool.isRequired
    show:               T.bool.isRequired

  computePosition: ->
    if @props.positionAlgorithm?
      return @props.positionAlgorithm @props.baseArea
    width = 240 # card default width
    supposeHeight = 200
    half = width / 2
    maxTop = window.innerHeight - supposeHeight
    top = Math.min @props.baseArea.bottom, maxTop
    xCenter = (@props.baseArea.left + @props.baseArea.right) / 2
    left = xCenter - half
    if left < 20 then left = 20 # mind the left edge
    if (left + width + 20) > window.innerWidth
      left = window.innerWidth - width - 20
    # return as style
    top: "#{top}px"
    left: "#{left}px"

  onPopoverClose: ->
    @props.onPopoverClose()

  renderLayer: (afterTransition) ->
    decorator = "is-#{@props.name or 'default'}"
    div null,
      if @props.show and afterTransition
        style = @computePosition()
        PopoverMenu style: style, decorator: decorator, onClose: @onPopoverClose,
          if @props.title?
            div className: 'header',
              span className: 'title', @props.title
          if @props.showClose
            span className: 'ti ti-remove', onClick: @onPopoverClose
          div className: "body #{decorator}",
            @props.children

  render: ->
    noscript()
