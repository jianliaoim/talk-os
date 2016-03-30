cx = require 'classnames'
React = require 'react'
assign = require 'object-assign'
PureRenderMixin = require 'react-addons-pure-render-mixin'

{ i } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'Icon'

  mixins: [ PureRenderMixin ]

  propTypes:
    name: T.string.isRequired
    size: T.number
    type: T.string
    color: T.string
    onClick: T.func
    className: T.string
    backgroundColor: T.string

  getDefaultProps: ->
    size: 16
    type: 'ti'
    onClick: (->)
    className: ''

  getStyle: ->
    assign {},
      { color: @props.color } if @props.color
      { fontSize: @props.size }
      { backgroundColor: @props.backgroundColor } if @props.backgroundColor

  onClick: (event) ->
    @props.onClick event

  render: ->
    icon = "#{ @props.type } #{ @props.type }-#{ @props.name }"
    className = cx icon, @props.className

    i className: className, style: @getStyle(), onClick: @onClick,
      @props.children
