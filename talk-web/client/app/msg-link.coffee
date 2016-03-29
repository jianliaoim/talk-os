React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

mixinMessageHandler = require '../mixin/message-handler'

T = React.PropTypes

div = React.createFactory 'div'
span = React.createFactory 'span'

module.exports = React.createClass
  displayName: 'msg-link'
  mixins: [mixinMessageHandler, PureRenderMixin]

  propTypes:
    message: T.instanceOf(Immutable.Map)

  onClick: ->
    @onLinkViewerShow()

  onIconClick: (event) ->
    event.stopPropagation()
    window.open @props.message.get('attachments').get(0).getIn(['data', 'redirectUrl'])

  render: ->
    quote = @props.message.get('attachments').get(0).get('data')
    imgStyle =
      backgroundImage: if quote.get('faviconUrl') then "url(#{quote.get('faviconUrl')})"

    textStyle =
      fontFamily: window.getComputedStyle?(document.body).fontFamily or 'serif'
      fontSize: 14

    title = quote.get('title') or quote.get('text')

    div className: 'msg-link msg-collection', onClick: @onClick,
      div className: 'preview', style: imgStyle
      div className: 'text', title
      if quote.get('redirectUrl')
        span className: 'icon icon-jump', onClick: @onIconClick
      @renderLinkViewer()
