React   = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'guide-circle'
  mixins: [PureRenderMixin]

  propTypes:
    onClick: T.func.isRequired

  onClick: (event) ->
    event.stopPropagation()
    @props.onClick()

  render: ->
    div className: 'guide-circle', onClick: @onClick,
      div className: 'inner'
