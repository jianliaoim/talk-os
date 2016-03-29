cx = require 'classnames'
xss = require 'xss'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'
assign = require 'object-assign'

query = require '../query'
mixinMessageHandler = require '../mixin/message-handler'
mixinMessageContent = require '../mixin/message-content'

lang = require '../locales/lang'

detect = require '../util/detect'
format = require '../util/format'
notifyActions = require '../actions/notify'
routerHandlers = require '../handlers/router'

QuoteSlim = React.createFactory require './quote-slim'
FileGlance = React.createFactory require './file-glance'
MessageToolbar = React.createFactory require './message-toolbar'
MessageAttachmentSlim = React.createFactory require './message-attachment-slim'
MessageInlineEditor = React.createFactory require './message-inline-editor'

RelativeTime = React.createFactory require '../module/relative-time'

LiteAudioSlim = React.createFactory require('react-lite-audio').liteAudioSlim

a = React.createFactory 'a'
div = React.createFactory 'div'
span = React.createFactory 'span'
strong = React.createFactory 'strong'

L = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-slim'
  mixins: [mixinMessageHandler, mixinMessageContent, PureRenderMixin]

  propTypes:
    isDuplicated: T.bool
    isUnread: T.bool
    selected: T.bool
    showActions: T.bool
    onClick: T.func
    onFileClick: T.func.isRequired
    message: T.instanceOf(Immutable.Map)
    isEditMode: T.bool

  getDefaultProps: ->
    isDuplicated: false
    isUnread:     false
    selected:     false
    showActions:  false
    isEditMode:   false

  onClick: ->
    @props.onClick? @props.message.get('_id')

  renderAttachmentRTF: ->
    return if not @props.message.get('attachments')?.size and @props.message.get('attachments').get(0).get('category') isnt 'rtf'
    attachment = @props.message.get('attachments').get(0)
    maybeImage = detect.imageUrlInHtml attachment.data.text
    html = format.htmlAsText attachment.data.text
    textLength = html.trim().length
    content = format.textAsAbbr html

    div onClick: @onPostViewerShow,
      span className: 'slim-post-text',
        if textLength is 0 and maybeImage then L('images-only') else content

  renderAttachmentQuote: ->
    return if not @props.message.get('attachments')?.size and @props.message.get('attachments').get(0).get('category') isnt 'quote'

  renderMessageAuthor: ->
    div className: 'avator',
      strong ref: 'author', className: 'name', onClick: @onAuthorClick,
        @getAuthorName()

  renderMessageBody: ->
    div className: 'container',
      if @props.message.get('body')?.length > 0
        @renderContent()
      @renderMessageAttachment()

  renderMessageAttachment: ->
    return if not @props.message.get('attachments')?.size
    div className: 'attachment',
      @props.message.get('attachments').map (attachment, index) =>
        data = attachment.get('data')
        switch attachment.get('category')
          when 'file'
            FileGlance key: index, progress: attachment.get('progress'), file: data, onClick: => @props.onFileClick(attachment)
          when 'quote'
            QuoteSlim key: index, quote: data, onClick: @onQuoteRedirect
          when 'rtf'
            QuoteSlim key: index, quote: data, onClick: @onPostViewerShow
          when 'snippet'
            QuoteSlim key: index, quote: data, onClick: @onSnippetViewerShow
          when 'speech'
            LiteAudioSlim
              key: index
              source: data.get('previewUrl')
              duration: data.get('duration')
              isUnread: @props.isUnread
          when 'message'
            _roomId = attachment.getIn(['data', 'room', '_id'])
            _teamId = attachment.getIn(['data', '_teamId'])
            _messageId = attachment.getIn(['data', '_id'])
            onClick = ->
              topics = query.topicsBy(recorder.getState(), _teamId)
              if topics.map((room) -> room.get('_id')).includes(_roomId)
                routerHandlers.room _teamId, _roomId, {search: _messageId}
              else
                notifyActions.info(lang.getText('topic-not-exists'))
            MessageAttachmentSlim
              key: index
              message: data
              onClick: onClick

  renderMessageSide: ->
    div className: 'side static-line',
      MessageToolbar message: @props.message
      RelativeTime data: (@props.message.get('updatedAt') or @props.message.get('createdAt'))

  renderSlimBody: ->
    # in case of empty link title
    firstAttachment =  @props.message.getIn(['attachments', 0]) or Immutable.Map()
    quoteTitle = firstAttachment.getIn(['data', 'title'])
    quoteText = firstAttachment.getIn(['data', 'title'])
    quoteContent = if quoteText then format.textAsAbbr format.htmlAsText quoteText else undefined

    div className: 'body',
      if @props.message.get('attachments')?.get(0).get('data')?.get('text').size
        @renderSlimPost()
      else if @props.message.get('attachments')?.get(0).get('data')?.get('category') is 'file'
        undefined
      else
        @renderContent()
      div className: 'actions static-line',
        MessageToolbar message: @props.message
        RelativeTime data: (@props.message.get('updatedAt') or @props.message.get('createdAt'))

      if firstAttachment.get('category') is 'file'
        FileGlance file: firstAttachment.get('data'), onClick: => @props.onFileClick(firstAttachment)
      if @props.message.get('attachments')?.get(0).get('category') is 'speech'
        LiteAudioSlim
          source: firstAttachment.getIn(['data', 'previewUrl'])
          isUnread: @props.isUnread
          duration: firstAttachment.getIn(['data', 'duration'])
      if firstAttachment.get('category') is 'quote'
        if firstAttachment.getIn(['data', 'redirectUrl'])?
          onClick = -> window.open firstAttachment.getIn(['data', 'redirectUrl'])
        else
          onClick = -> return false
        div className: 'quote line', onClick: onClick,
          if firstAttachment.getIn(['data', 'authorName'])?
            span className: 'author', firstAttachment.getIn(['data', 'authorName'])
          if firstAttachment.getIn(['data', 'title'])?
            span className: 'short text muted', (format.htmlAsText quoteTitle)
          if quoteContent
            div className: 'content', quoteContent

  renderInlineMessageEditor: ->
    MessageInlineEditor
      message: @props.message

  renderMessage: ->
    return if not @props.message?
    _userId = query.userId(recorder.getState())

    messageReceiptData = @getMessageReceiptData()
    isDuplicated = @props.isDuplicated and not @props.isEditMode

    classMessage = cx 'message-slim', messageReceiptData.class,
      'is-duplicated': isDuplicated
      'be-mine': @props.message.getIn(['creator', '_id']) is _userId
      'is-robot': @props.message.getIn(['creator', 'isRobot'])
      'is-selected': @props.selected
      'is-local': @props.message.get('isLocal')

    props = assign
      className: classMessage
      onClick: @onClick
    , messageReceiptData.props

    div props,
      unless isDuplicated
        @renderMessageAuthor()

      if @props.isEditMode
        @renderInlineMessageEditor()
      else
        @renderMessageBody()

      @renderMessageSide()

      @renderMemberCard()
      @renderPostViewer()
      @renderSnippetViewer()

  render: ->
    @renderMessage()
