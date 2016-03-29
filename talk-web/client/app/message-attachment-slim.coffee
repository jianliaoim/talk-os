React = require 'react'
Immutable = require 'immutable'
mixinMessageContent = require '../mixin/message-content'

div    = React.createFactory 'div'
strong = React.createFactory 'strong'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-attachment-slim'
  mixins: [mixinMessageContent]

  propTypes:
    message: T.instanceOf(Immutable.Map)
    onClick: T.func

  renderTitle: ->
    strong {},
      @props.message.getIn(['creator', 'name'])

  render: ->
    div className: 'message-attachment-slim', onClick: @props.onClick,
      @renderTitle()
      @renderContent()
