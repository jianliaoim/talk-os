React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
emojiUtil = require '../util/emoji'

div    = React.createFactory 'div'
span   = React.createFactory 'span'
hr     = React.createFactory 'hr'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-system'
  mixins: [PureRenderMixin]

  propTypes:
    message: T.object.isRequired
    type: T.oneOf ['rich', 'slim']

  renderContent: ->
    content = @props.message.get('body')
    .replace /\{\{__([\w-]+)\}\}/g, (raw, key) ->
      text = lang.getText(key)
      if text then text else raw
    content = emojiUtil.replace content

    span
      dangerouslySetInnerHTML:
        __html: content

  renderNames: ->
    if @props.message.has('creators')
      @props.message.get('creators')
        .map (creator) ->
          creator?.get('name') or lang.getText('someone')
        .join(', ')
    else
      @props.message.getIn(['creator', 'name']) or lang.getText('someone')

  renderRich: ->
    div className: "message-system is-#{@props.type} line",
      @renderNames()
      @renderContent()

  render: ->
    @renderRich()
