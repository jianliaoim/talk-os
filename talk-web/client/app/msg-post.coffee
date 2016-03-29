React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

detect = require '../util/detect'
format = require '../util/format'

lang = require '../locales/lang'

mixinMessageHandler = require '../mixin/message-handler'

T = React.PropTypes

div = React.createFactory 'div'

module.exports = React.createClass
  displayName: 'msg-post'
  mixins: [mixinMessageHandler, PureRenderMixin]

  propTypes:
    message: T.instanceOf(Immutable.Map)

  onClick: ->
    @onPostViewerShow()

  render: ->
    return if not @props.message.get('attachments').size
    target = @props.message.get('attachments').filter (attachment) ->
      attachment.get('category') is 'rtf'
    return if not target.size
    rtf = target.get(0).get('data')
    maybeImage = detect.imageUrlInHtml rtf.get('text')
    imgStyle =
      backgroundImage: if maybeImage? then "url(#{maybeImage})"
    text = format.htmlAsText(rtf.get('title') or rtf.get('text')).trim()

    if (text.length is 0) and maybeImage
      text = lang.getText('images-only')

    div className: 'msg-post msg-collection', onClick: @onClick,
      div className: 'preview', style: imgStyle
      div className: 'text', text
      @renderPostViewer()
