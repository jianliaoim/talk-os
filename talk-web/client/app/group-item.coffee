React = require 'react'
cx = require 'classnames'
Immutable = require 'immutable'

Icon = React.createFactory require '../module/icon'

{ div, span } = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'group-item'

  propTypes:
    group: T.instanceOf(Immutable.Map).isRequired
    showSelect: T.bool
    isSelected: T.bool
    onClick: T.func
    hover: T.bool

  getDefaultProps: ->
    showSelect: false
    isSelected: false
    hover: false

  onClick: ->
    @props.onClick?(@props.group)

  render: ->
    cxBody = cx 'group-item', 'flex-horiz',
      'is-clickable': @props.onClick?
      hover: @props.hover

    div className: cxBody, onClick: @onClick,
      Icon name: 'users', size: 18, className: 'flex-static group-icon'
      div className: 'body flex-fill',
        span className: 'name text-overflow flex-static', @props.group.get('name')
        span className: 'flex-static member-count', " (#{@props.group.get('_memberIds').size})"
      if @props.showSelect and @props.isSelected
        Icon name: 'tick', size: 18, className: 'flex-static'
