cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'

format = require '../util/format'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, span, strong } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-name'
  mixins: [PureRenderMixin]

  propTypes:
    large: T.bool.isRequired
    showSource: T.bool.isRequired
    onClick: T.func.isRequired
    showUnread: T.bool
    data: T.instanceOf(Immutable.Map)

  getDefaultProps: ->
    showUnread: true

  onClick: ->
    @props.onClick @props.data.get('_id')

  render: ->
    unread = @props.data.get('unread')
    className = cx 'team-name', 'item', 'line', 'flex-horiz', 'flex-vcenter',
      'is-large': @props.large

    div className: className, onClick: @onClick,
      span className: 'icon icon-users icon-char flex-static'
      strong className: 'flex-fill short name ', @props.data.get('name')
      if @props.showSource and @props.data.get('source')
        span className: "source is-#{@props.data.get('source')}"
      if @props.showUnread and unread > 0
        span className: 'flex-static icon-unread', (format.escape100 unread)
