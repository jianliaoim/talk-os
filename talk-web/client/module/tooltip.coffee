# Tooltip component using Tether Drop
# http://github.hubspot.com/drop/

React = require 'react'
ReactDOM = require 'react-dom'
assign = require 'object-assign'
type = require '../util/type'
isEqual = require 'lodash.isequal'

if typeof window isnt 'undefined'
  Drop = require 'tether-drop'

T = React.PropTypes
div = React.DOM.div

TETHER_DEFAULT_OPTIONS =
  openOn: 'hover'
  remove: true
  position: 'bottom center'
  classes: 'drop-theme-arrows'
  hoverOpenDelay: 300
  tetherOptions:
    constraints: [{
        to: 'window',
        attachment: 'together'
        pin: true
    }]

module.exports = React.createClass
  displayName: 'tooltip'

  propTypes:
    # react component or raw js string inside the tooltip
    template: T.oneOfType([T.string, T.func]).isRequired
    # tether options
    options: T.object
    # accepts children

  getDefaultProps: ->
    options: {}

  shouldComponentUpdate: (nextProps) ->
    sameTemplate = isEqual(nextProps.template, @props.template)
    sameChildren = isEqual(nextProps.children, @props.children)
    not sameTemplate or not sameChildren

  componentDidMount: ->
    @_node = null
    @_drop = null
    @initDrop()
    @updateDrop()

  componentDidUpdate: ->
    @updateDrop()

  componentWillUnmount: ->
    if @_node
      ReactDOM.unmountComponentAtNode(@_node)
    @_drop.destroy()

  initDrop: ->
    options = assign TETHER_DEFAULT_OPTIONS, @props.options,
      target: ReactDOM.findDOMNode(this)
      content: ' '
    @_drop = new Drop(options)

  updateDrop: ->
    if type.isFunction(@props.template)
      @_node = document.createElement('div')
      child = React.Children.only(@props.template())
      ReactDOM.render(child, @_node)
      dom = ReactDOM.findDOMNode(@_node)
      innerHTML = dom.innerHTML
    else
      innerHTML = @props.template

    @_drop.content.innerHTML = innerHTML
    @_drop.position()

  render: ->
    React.cloneElement @props.children
