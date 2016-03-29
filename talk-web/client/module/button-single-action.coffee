React = require 'react'
assign = require 'object-assign'
cx = require 'classnames'

T = React.PropTypes

LiteLoadingCircle = React.createFactory require('react-lite-misc').LoadingCircle

button = React.DOM.button

module.exports = React.createClass
  displayName: 'single-action-button'

  getInitialState: ->
    isLoading: false

  onComplete: ->
    @setState isLoading: false

  onClick: ->
    return if @state.isLoading
    @setState isLoading: true
    @props.onClick @onComplete

  content: ->
    if @state.isLoading
      LiteLoadingCircle
        size: 32 # WARN: will cause problem on buttons with height != 32
        stroke: 'white'
    else
      @props.children

  render: ->
    className = cx @props.className,
      'button-single-action': true
      'is-loading': @state.isLoading
      'is-disabled': @state.isLoading

    props = assign {}, @props,
      onClick: @onClick
      className: className

    button props, @content()
