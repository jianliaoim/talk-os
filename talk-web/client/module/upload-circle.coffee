React = require 'react'
assign = require 'object-assign'

{ div, svg, circle } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'upload-cicle'

  propTypes:
    size: T.number
    progress: T.number
    strokeWidth: T.number

  getDefaultProps: ->
    size: 72
    progress: 0
    strokeWidth: 2

  getInitialState: ->
    fill: 0
    perimeter: Math.ceil (@props.size - 2 * @props.strokeWidth) * Math.PI

  componentWillReceiveProps: (nextProps) ->
    @setState fill: @state.perimeter * nextProps.progress

  render: ->
    commonProps =
      r: (@props.size / 2) - @props.strokeWidth
      cx: (@props.size / 2)
      cy: (@props.size / 2)
      strokeWidth: @props.strokeWidth

    div className: 'upload-circle flex-vert flex-center flex-vcenter',
      svg className: 'circle', width: @props.size, height: @props.size,
        circle assign commonProps, className: 'inner-background'
        circle assign commonProps, className: 'inner-progress', style: strokeDasharray: "#{ @state.fill } #{ @state.perimeter }"
      @props.children
