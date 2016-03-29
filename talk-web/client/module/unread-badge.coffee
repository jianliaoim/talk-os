cx = require 'classnames'
React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

{ i, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'UnreadBadge'

  mixins: [ PureRenderMixin ]

  propTypes:
    size: T.number
    round: T.bool
    oval: T.bool
    number: T.number
    showNumber: T.bool

  getDefaultProps: ->
    size: 14
    round: false
    oval: false
    number: 0
    showNumber: true

  render: ->
    if @props.number > 0
      className = cx 'unread-badge',
        round: @props.round

      if @props.oval
        style =
          height: @props.size
          minWidth: @props.size
          borderRadius: @props.size / 2
      else
        style =
          width: @props.size
          height: @props.size

      unless @props.showNumber then style.padding = 0

      number =
        if @props.showNumber
          if @props.number > 99 then 99 else @props.number
        else
          ''

      i className: className, style: style, number
    else
      noscript()
