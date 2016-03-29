React = require 'react'
PureRenderMixin = PureRenderMixin

div  = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'notify-banner'
  mixin: [PureRenderMixin]

  propsTypes:
    data: T.object.isRequired # Immutable

  render: ->
    type = 'is-' + (@props.data.get('type') or 'empty')
    div className: "notify-banner #{type}", @props.data.get('text')
