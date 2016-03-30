React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

detect = require '../util/detect'
format = require '../util/format'

lang = require '../locales/lang'

mixinMessageHandler = require '../mixin/message-handler'

T = React.PropTypes

div  = React.createFactory 'div'
span = React.createFactory 'span'

module.exports = React.createClass
  displayName: 'msg-snippet'
  mixins: [mixinMessageHandler, PureRenderMixin]

  propTypes:
    message: T.object.isRequired

  onClick: ->
    @onSnippetViewerShow()

  render: ->
    if @props.message.get('attachments').get(0).getIn(['data', 'title']) isnt ''
      content = @props.message.get('attachments').get(0).getIn(['data', 'title'])
    else if @props.message.get('attachments').get(0).getIn(['data', 'text']) isnt ''
      content = @props.message.get('attachments').get(0).getIn(['data', 'text'])
    else
      content = '...'

    text = content.trim()

    div className: 'msg-snippet msg-collection', onClick: @onClick,
      div className: 'preview',
        span className: 'ti ti-pre'
      div className: 'text', text
      @renderSnippetViewer()
