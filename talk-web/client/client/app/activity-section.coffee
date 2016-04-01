React = require 'react'
moment = require 'moment'

{div, time} = React.DOM

module.exports = React.createClass

  propTypes:
    children: React.PropTypes.element.isRequired
    display: React.PropTypes.string.isRequired

  render: ->
    div className: 'activity-section',
      time className: 'timestamp', @props.display
      @props.children
