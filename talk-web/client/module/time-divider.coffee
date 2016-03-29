React = require 'react'
time = require '../util/time'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div  = React.createFactory 'div'
span = React.createFactory 'span'
hr   = React.createFactory 'hr'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'time-divider'
  mixins: [PureRenderMixin]

  propTypes:
    data: T.string.isRequired

  render: ->
    text = time.formatDayGap @props.data

    div className: 'time-divider muted flex-horiz flex-vcenter',
      hr className: 'flex-fill'
      span className: 'time flex-static', text
