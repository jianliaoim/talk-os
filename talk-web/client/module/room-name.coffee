cx = require 'classnames'
React = require 'react'

lang = require '../locales/lang'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'room-name'
  mixins: [ PureRenderMixin ]

  propTypes:
    name: T.string.isRequired
    className: T.string

  render: ->
    name = @props.name
    if name is 'general'
      name = lang.getText 'room-general'

    span className: cx(@props.className), name
