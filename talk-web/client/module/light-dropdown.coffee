React = require 'react'
classnames = require 'classnames'

div = React.createFactory 'div'

T = React.PropTypes

DropdownMenu = React.createFactory React.createClass
  displayName: 'light-dropdown-menu'

  propTypes:
    onClose: T.func

  componentDidMount: ->
    event = new window.MouseEvent 'click',
      view: window
      bubbles: true
      cancelable: true
    window.dispatchEvent event
    window.addEventListener 'click', @onWindowClick

  componentWillUnmount: ->
    window.removeEventListener 'click', @onWindowClick

  onWindowClick: ->
    @props.onClose()

  onClick: ->
    @props.onClose()

  render: ->
    div className: 'dropdown', onClick: @onClick,
      @props.children


module.exports = React.createClass
  displayName: 'light-dropdown'

  propTypes:
    show: T.bool.isRequired
    onToggle: T.func.isRequired
    displayText: T.string
    defaultText: T.string.isRequired
    name: T.string

  getDefaultProps: ->
    name: 'default'

  getInitialState: ->
    {}

  onDisplayClick: (event) ->
    @props.onToggle()

  onClick: (event) ->
    event.stopPropagation()

  onDropdownClose: ->
    @props.onToggle()

  render: ->
    className = classnames 'light-dropdown', "is-for-#{@props.name}",
      'is-chosen': @props.displayText?

    div className: className, onClick: @onClick,
      div className: 'display', onClick: @onDisplayClick,
        @props.displayText or @props.defaultText
      div className: 'triangle'
      if @props.show
        DropdownMenu onClose: @onDropdownClose,
          @props.children
