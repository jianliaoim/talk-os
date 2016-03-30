cx = require 'classnames'
React = require 'react'

lang = require '../locales/lang'

Icon = React.createFactory require './icon'

{ span, div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'LaunchButton'

  propTypes:
    active: T.bool
    onClick: T.func

  getDefaultProps: ->
    active: false
    onClick: (->)

  onClick: (event) ->
    @props.onClick event

  render: ->
    div className: 'btn-launch', onClick: @onClick,
      Icon name: 'pencil', size: 18
      span className: 'text', lang.getText 'launch-jianliao'
