React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div  = React.createFactory 'div'
span = React.createFactory 'span'
T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'light-checkbox'
  mixins: [PureRenderMixin]

  propTypes:
    checked:  T.bool.isRequired
    event:    T.string
    name:     T.string.isRequired
    onClick:  T.func.isRequired
    locale:   T.string

  getInitialState: ->
    open: false

  onClick: ->
    @props.onClick @props.event

  onMouseEnter: ->
    @setState open: true

  onMouseLeave: ->
    @setState open: false

  render: ->
    iconClass = cx
      icon: true
      'icon-tick': @props.checked

    div className: 'light-checkbox line', onClick: @onClick, onMouseEnter: @onMouseEnter, onMouseLeave: @onMouseLeave,
      span className: iconClass
      span className: 'name', @props.name
      span null,
        # special rule: if locale is empty string, dont show
        if @props.locale? and @state.open and @props.locale
          div className: 'title', @props.locale
