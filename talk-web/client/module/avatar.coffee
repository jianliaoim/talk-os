cx = require 'classnames'
React = require 'react'
assign = require 'object-assign'
PureRenderMixin = require 'react-addons-pure-render-mixin'

{ i } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'avatar'

  mixins: [ PureRenderMixin ]

  propTypes:
    src: T.string
    size: T.oneOf [ 'small', 'normal', 'large', 'medium' ]
    color: T.string
    shape: T.oneOf [ 'corner', 'round' ]
    onClick: T.func
    className: T.string
    backgroundColor: T.string

  getDefaultProps: ->
    src: ''
    size: 'normal'
    shape: ''
    onClick: (->)
    className: ''

  getClassName: ->
    cx @props.className, 'avatar', (if @props.size isnt 'normal' then @props.size), @props.shape

  getStyle: ->
    if @props.backgroundColor? and not @props.src
      backgroundColor =
        backgroundColor: @props.backgroundColor

    if @props.src.length > 0
      backgroundImage =
        backgroundImage: "url(#{ @props.src })"

    assign {}, backgroundColor, backgroundImage

  onClick: (event) ->
    @props.onClick event

  render: ->
    i className: @getClassName(), style: @getStyle(), onClick: @onClick,
      @props.children
