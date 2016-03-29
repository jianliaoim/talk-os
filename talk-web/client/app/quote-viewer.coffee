cx = require 'classnames'
xss = require 'xss'
React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

handlers = require '../handlers'

messageActions = require '../actions/message'

lang = require '../locales/lang'
detect = require '../util/detect'

UserAlias = React.createFactory require './user-alias'
MessageToolbar = React.createFactory require './message-toolbar'

{ a, div, span, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'quote-viewer'
  mixins: [ PureRenderMixin ]

  propTypes:
    message: T.instanceOf(Immutable.Map).isRequired
    onClose: T.func.isRequired
    isFavorite: T.bool

  getDefaultProps: ->
    isFavorite: false

  getQuote: ->
    return if @props.message.get('attachments').size is 0

    quotes = @props.message.get 'attachments'
    .filter (attachment) ->
      attachment.get('category') is 'quote'

    return if quotes.size is 0

    quotes
      .getIn [0, 'data']
      .update (cursor) ->
        text = xss(cursor.get('text') or '')
        cursor
          # 收到的text可能是html也可能是纯文本，
          # 两种情况里面都可能会有`\n`
          # 需要正确判断他是不是html来正确渲染换行
          .set 'isPlaintext', not detect.isHtml(text)
          .set 'text', text

  onClose: ->
    @props.onClose()

  onContentClick: (event) ->
    if event.target.tagName is 'A'
      event.preventDefault()

      href = event.target.href or ''

      if href.indexOf(location.origin) is 0
        routePath = href.substr(location.origin.length)
        handlers.routerGoPath routePath
      else
        window.open href

  render: ->
    quote = @getQuote()

    return noscript() if not quote?

    avatar = @props.message.get('authorAvatarUrl') or @props.message.getIn(['creator', 'avatarUrl'])
    style =
      if avatar.length isnt 0
        backgroundImage: "url(#{ avatar })"
      else {}

    if quote.has 'redirectUrl'
      contentStyle =
        height: "#{ window.innerHeight - 170 }px"
    else
      contentStyle =
        height: "#{ window.innerHeight - 130 }px"

    contentClass = cx 'content-area', 'rich-text',
      'is-plaintext': quote.get('isPlaintext')

    div className: 'quote-viewer',
      div className: 'header',
        span className: 'avatar img-circle', style: style
        UserAlias
          _teamId: @props.message.get('_teamId')
          _userId: @props.message.get('_creatorId')
          replaceMe: true
          defaultName: @props.message.get('authorName') or @props.message.getIn(['creator', 'name'])
        unless @props.isFavorite
          MessageToolbar message: @props.message, hideMenu: true, showInline: true
        a className: 'icon icon-remove', onClick: @onClose
      div className: contentClass, style: contentStyle, onClick: @onContentClick, dangerouslySetInnerHTML: __html: quote.get 'text'
      if quote.has 'redirectUrl'
        div className: 'footer',
          if quote.get('category') is 'mailgun'
            a className: 'button is-link', href: quote.get('redirectUrl'), target: '_blank',
              lang.getText 'reply-to-mail'
          else
            a className: 'button is-link', href: quote.get('redirectUrl'), target: '_blank',
              lang.getText 'jump-to-origin'
