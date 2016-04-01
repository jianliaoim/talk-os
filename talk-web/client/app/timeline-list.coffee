React = require 'react'

{div} = React.DOM

module.exports = React.createClass

  propTypes:
    children: React.PropTypes.any.isRequired

  render: ->
    div className: 'timeline-list thin-scroll',
      @props.children
