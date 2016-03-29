cx = require 'classnames'
xss = require 'xss'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'
assign = require 'object-assign'

query = require '../query'
handlers = require '../handlers'
eventBus = require '../event-bus'

notifyActions = require '../actions/notify'
messageActions = require '../actions/message'
routerHandlers = require '../handlers/router'

mixinMessageHandler = require '../mixin/message-handler'
mixinMessageContent = require '../mixin/message-content'

lang = require '../locales/lang'

time = require '../util/time'
colors = require '../util/colors'
detect = require '../util/detect'
snippetUtil = require '../util/snippet'

MessageToolbar = React.createFactory require './message-toolbar'
UserAlias = React.createFactory require './user-alias'
MessageInlineEditor = React.createFactory require './message-inline-editor'

Tag = React.createFactory require './tag'
Icon = React.createFactory require '../module/icon'
AttachImage = React.createFactory require './attach-image'
RelativeTime = React.createFactory require '../module/relative-time'
SnippetAttachment = React.createFactory require './snippet-attachment'

LiteAudio = React.createFactory require('react-lite-audio').liteAudio
LiteModal = React.createFactory require('react-lite-layered').Modal

MessageFormsFile = React.createFactory require 'talk-message-forms/lib/default/file'
MessageFormsQuote = React.createFactory require 'talk-message-forms/lib/default/quote'
MessageFormsRTF = React.createFactory require 'talk-message-forms/lib/default/rtf'
MessageFormsSpeech = React.createFactory require 'talk-message-forms/lib/default/speech'
MessageFormsMessage = React.createFactory require 'talk-message-forms/lib/default/message'
MessageAttachment = React.createFactory require './message-attachment'
UploadCircle = React.createFactory require '../module/upload-circle'

{ div, span } = React.DOM
T = React.PropTypes
ReactCSSTransitionGroup = React.createFactory require 'react-addons-css-transition-group'

module.exports = React.createClass
  displayName: 'message-rich'
  mixins: [mixinMessageHandler, mixinMessageContent, PureRenderMixin]

  propTypes:
    isFavorite: T.bool
    isDuplicated: T.bool
    isUnread: T.bool
    selected: T.bool
    showActions: T.bool
    showTags: T.bool
    canEdit: T.bool
    onClick: T.func
    onFileClick: T.func.isRequired
    onTagClick: T.func
    message: T.instanceOf(Immutable.Map)
    isEditMode: T.bool

  getDefaultProps: ->
    isFavorite: false
    isDuplicated: false
    isUnread: false
    selected: false
    showActions: false
    showTags: false
    canEdit: true
    isEditMode: false

  getInitialState: ->
    {}

  onClick: ->
    @props.onClick? @props.message.get('_id')

  renderMessageAuthor: ->
    return if not @props.message.get('creator')?

    style =
      if @props.message.get('authorAvatarUrl')?
        backgroundImage: "url(#{ @props.message.get('authorAvatarUrl') })"
      else
        backgroundImage: "url(#{ @props.message.getIn(['creator', 'avatarUrl']) })"

    div
      ref: 'author'
      className: 'author flex-static'
      if @props.message.getIn ['attachments', 0, 'isUploading']
        UploadCircle
          progress: @props.message.getIn ['attachments', 0, 'progress']
          size: 48,
          div className: 'avatar img-circle background-cover', style: style, onClick: @onQuitUploading,
            Icon size: 20, name: 'remove', className: 'quit'
      else
        span className: 'avatar flex-static img-circle background-cover', style: style, onClick: @onAuthorClick

  onQuitUploading: ->
    fileInfo = @props.message.getIn(['attachments', 0, 'data']).toJS()
    handlers.fileAbort {fileInfo}

  renderMessageContainer: ->
    div className: 'container flex-fill flex-vert',
      @renderMessageTitle()
      if @props.isEditMode
        @renderInlineMessageEditor()
      else
        @renderMessageBody()
      @renderTagList()

  renderMessageBody: ->
    cxBody = cx 'body', 'flex-vend', 'flex-horiz',
      'no-attachment': @props.message.get('attachments').size is 0

    div className: cxBody,
      @renderMessageContent()
      @renderEditedMessage()
      @renderMessageAttachment()
      div className: 'toolbar flex-static',
        @renderToolbar()

  renderMessageTitle: ->
    div className: 'title flex-fill flex-horiz flex-vcenter',
      UserAlias _teamId: @props.message.get('_teamId'), _userId: @props.message.get('_creatorId'), defaultName: @getAuthorName(), onClick: @onAuthorClick
      RelativeTime data: @props.message.get('createdAt'), edited: @props.message.get('updatedAt')

  renderMessageContent: ->
    return if not @props.message.get('body')?.length
    @renderContent()

  renderEditedMessage: ->
    return null if not @props.isDuplicated
    createdAt = @props.message.get('createdAt')
    updatedAt = @props.message.get('updatedAt')
    return null if not time.isMessageEdited(createdAt, updatedAt)
    editedTime = time.calendar updatedAt
    div className: 'edit-time',
      "(#{lang.getText('update-at').replace('{{time}}', editedTime)})"

  renderMessageAttachment: ->
    return if not @props.message.get('attachments')?.size

    widthBoundary = Math.max(360, Math.min(window.innerWidth - 400, 680))
    heightBoundary = Math.max(360, Math.min(window.innerHeight - 500, 510))

    @props.message.get('attachments').map (attachment, index) =>
      switch attachment.get('category')
        when 'file'
          fileType = attachment.getIn(['data', 'fileType'])
          if detect.isImageWithPreview(attachment.get('data'))
            onClick = =>
              if attachment.get('isUploading') then ( -> ) else @props.onFileClick(attachment)
            AttachImage
              key: index
              attachment: attachment
              onClick: onClick
              heightBoundary: heightBoundary
              widthBoundary: widthBoundary
          else
            color = colors.files[fileType] or colors.files['file']
            MessageFormsFile
              key: index
              attachment: attachment.toJS()
              color: color
              onClick: => @props.onFileClick(attachment)
        when 'quote'
          onQuoteClick = =>
            @onQuoteViewerShow()
          MessageFormsQuote
            key: index
            lang: lang.getLang()
            attachment: attachment.toJS()
            onClick: onQuoteClick
        when 'rtf'
          MessageFormsRTF
            key: index
            attachment: attachment.toJS()
            onClick: @onPostViewerShow
        when 'snippet'
          SnippetAttachment
            key: index
            onClick: @onSnippetViewerShow
            attachment: attachment.toJS()
            getCodeType: snippetUtil.getHighlightJS
        when 'speech'
          div className: 'attachment-speech',
            LiteAudio
              duration: attachment.getIn ['data', 'duration']
              isUnread: @props.isUnread
              source: attachment.getIn ['data', 'previewUrl']
        when 'message'
          _roomId = attachment.getIn(['data', 'room', '_id'])
          _messageId = attachment.getIn(['data', '_id'])
          _teamId = attachment.getIn(['data', '_teamId'])
          onClick = ->
            topics = query.topicsBy(recorder.getState(), _teamId)
            if topics.map((room) -> room.get('_id')).includes(_roomId)
              routerHandlers.room _teamId, _roomId, {search: _messageId}
            else
              notifyActions.info lang.getText('topic-not-exists')
          MessageFormsMessage
            key: index
            onClick: onClick
            MessageAttachment
              message: attachment.get('data')

  renderTagList: ->
    return if not @props.message.get('tags')?.size
    tags = @props.message.get('tags')
    if @props.showTags and tags?.size > 0
      div className: 'tag-list',
        ReactCSSTransitionGroup
          transitionName: 'fade'
          className: 'fade'
          transitionEnterTimeout: 200
          transitionLeaveTimeout: 200
          tags.map (tag) =>
            Tag
              key: tag.get('_id')
              tag: tag
              editable: false
              onTagClick: if @props.preview then (->) else @props.onTagClick
              _teamId: @props.message.get('_teamId')

  renderToolbar: ->
    if @props.showActions
      div className: 'toolbar flex-static',
        MessageToolbar message: @props.message

  renderInlineMessageEditor: ->
    MessageInlineEditor
      message: @props.message

  renderMessage: ->
    return if not @props.message?
    _userId = query.userId(recorder.getState())

    messageReceiptData = @getMessageReceiptData()

    classMessage = cx 'message-rich', 'flex-horiz', 'flex-vstart', messageReceiptData.class,
      'is-duplicated': @props.isDuplicated and not @props.isEditMode
      'be-mine': @props.message.getIn(['creator', '_id']) is _userId
      'is-robot': @props.message.getIn(['creator', 'isRobot'])
      'is-selected': @props.selected
      'is-local': @props.message.get('isLocal')

    props = assign
      className: classMessage
      onClick: @onClick
    , messageReceiptData.props

    div props,
      @renderMessageAuthor()
      @renderMessageContainer()
      @renderMemberCard()
      @renderPostViewer()
      @renderQuoteViewer()
      @renderSnippetViewer()

  render: ->
    @renderMessage()
