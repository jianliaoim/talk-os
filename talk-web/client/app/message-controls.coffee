cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
uploadUtil  = require '../util/upload'

query = require '../query'
eventBus = require '../event-bus'
handlers = require '../handlers'

draftActions = require '../actions/draft'
messageActions = require '../actions/message'

lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'
mixinSelectEmoji = require '../mixin/select-emoji'

util = require '../util/util'
analytics = require '../util/analytics'

PostEditor = React.createFactory require './post-editor'
GuideAnchor = React.createFactory require './guide-anchor'
SnippetEditor = React.createFactory require './snippet-editor'

Icon = React.createFactory require '../module/icon'
Tooltip = React.createFactory require '../module/tooltip'

LiteModal = React.createFactory require('react-lite-layered').Modal

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ a, div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-controls'
  mixins: [ mixinSelectEmoji, mixinSubscribe, PureRenderMixin ]

  propTypes:
    _toId: T.string
    _roomId: T.string
    _teamId: T.string.isRequired
    _storyId: T.string
    _channelId: T.string
    _channelType: T.string
    showAt: T.bool
    showEmoji: T.bool
    showFile: T.bool
    showPost: T.bool
    showSnippet: T.bool
    showMarkdown: T.bool
    activeMarkdown: T.bool
    clearInputText: T.func
    onEmojiSelect: T.func

  getDefaultProps: ->
    showAt: true
    showEmoji: true
    showFile: true
    showPost: true
    showSnippet: true
    showMarkdown: true

  getInitialState: ->
    post: @getPost()
    snippet: @getSnippet()
    showNewPost: false
    showConvertToPost: false
    showSnippetEditor: false

  componentDidMount: ->
    @_rootEl = @refs.root

    @subscribe recorder, =>
      @setState
        post: @getPost()
        snippet: @getSnippet()

  componentWillUnmount: ->
    if @props.showFile
      @uploader?.destroy()

  getUserData: ->
    _toId: @props._toId
    _roomId: @props._roomId
    _teamId: @props._teamId
    _storyId: @props._storyId
    _creatorId: query.userId(recorder.getState())
    creator: query.user(recorder.getState())

  getEmojiTableBaseArea: ->
    if @_rootEl?
      @_rootEl.parentNode.getBoundingClientRect()
    else
      {}

  getPost: ->
    _channelId = @props._channelId
    query.draftsPostBy(recorder.getState(), @props._teamId, _channelId)

  getSnippet: ->
    _channelId = @props._channelId
    query.draftsSnippetBy(recorder.getState(), @props._teamId, _channelId)

  onEmojiSelect: (data) ->
    @onEmojiTableClose()
    @props.onEmojiSelect data

  onMarkdownClick: (event) ->
    event.preventDefault()
    draftActions.toggleMarkdown (not @props.activeMarkdown)

  onMentionClick: (event) ->
    event.preventDefault()
    @props.onMentionClick()
    analytics.clickAtButton()

  onNewPostClick: (event) ->
    event.preventDefault()
    @setState showNewPost: true

  onConvertPostClick: (event) ->
    event.preventDefault()
    @setState showConvertToPost: true

  onPostClose: (post) ->
    @setState
      showNewPost: false
      showConvertToPost: false

    if not post?
      return
    _teamId = @props._teamId
    _channelId = @props._channelId

    if post.text.length or post.title.length
      draftActions.savePost _teamId, _channelId, post
    else
      draftActions.clearPost _teamId, _channelId

  onSubmitPost: (clearInputText) ->
    _userId = query.userId(recorder.getState())
    ({title, text}) =>
      data =
        _teamId: @props._teamId
        _toId: @props._toId or undefined
        _roomId: @props._roomId or undefined
        _storyId: @props._storyId or undefined
        _creatorId: _userId
        body: ''
        attachments: [
          category: 'rtf',
          data:
            text: text
            title: title
        ]

      success = =>
        clearInputText()
        draftActions.clearPost @props._teamId, @props._channelId
        eventBus.emit 'dirty-action/new-message'
        @setState
          showNewPost: false
          showConvertToPost: false

      fail = =>
        draftActions.savePost @props._teamId, @props._channelId, data
        @setState
          showNewPost: false
          showConvertToPost: false

      messageActions.messageCreate data, success, fail

  renderPostEditor: ->
    if @state.showNewPost
      post = @getPost()
      if post?
        defaultText = post.get('text')
        defaultTitle = post.get('title')

    defaultText or= ''
    defaultTitle or= ''

    clearInputText = if @state.showConvertToPost then @props.clearInputText else (->)

    showPost = @state.showNewPost or @state.showConvertToPost
    LiteModal name: 'post-editor', show: showPost, onCloseClick: @onPostClose,
      PostEditor
        _teamId: @props._teamId
        _channelId: @props._channelId
        _channelType: @props._channelType
        onClose: @onPostClose
        onSubmit: @onSubmitPost(clearInputText)
        text: defaultText
        title: defaultTitle
        draftMode: true

  onSnippetEditorClick: (event) ->
    event.preventDefault()
    @setState showSnippetEditor: true

  onSnippetEditorClose: ->
    @setState
      showSnippetEditor: false

  onSubmitSnippet: (content) ->
    _userId = query.userId(recorder.getState())
    data =
      _teamId: @props._teamId
      _toId: @props._toId or undefined
      _roomId: @props._roomId or undefined
      _storyId: @props._storyId or undefined
      _creatorId: _userId
      attachments: [
        category: 'snippet'
        data:
          codeType: content.codeType
          text: content.text
          title: content.title
      ]

    success = =>
      draftActions.clearSnippet @props._teamId, @props._channelId
      eventBus.emit 'dirty-action/new-message'
      @setState
        showSnippetEditor: false

    fail = =>
      draftActions.saveSnippet @props._teamId, @props._channelId, data
      @setState
        showSnippetEditor: false

    messageActions.messageCreate data, success, fail

  onFileClick: (event) ->
    uploadUtil.handleClick
      multiple: true
      onCreate: handlers.fileCreate
      onProgress: handlers.fileProgress
      onSuccess: handlers.fileSuccess
      onError: handlers.fileError
      metaData: handlers.file.getNewMessageInfo()

  # rendereres

  renderSnippetEditor: ->
    LiteModal name: 'snippet-editor', show: @state.showSnippetEditor, onCloseClick: @onSnippetEditorClose,
      SnippetEditor
        _toId: @props._toId
        _roomId: @props._roomId
        _teamId: @props._teamId
        _storyId: @props._storyId
        onClose: @onSnippetEditorClose
        onSubmit: @onSubmitSnippet
        draftMode: true
        attachment: @state.snippet?.toJS()

  renderAt: ->
    if @props.showAt
      a className: 'action', onClick: @onMentionClick,
        Icon name: 'at', size: 18

  renderEmoji: ->
    if @props.showEmoji
      a className: 'action', onClick: @onEmojiTableClick,
        Icon name: 'emoji', size: 20

  renderFile: ->
    if @props.showFile
      Tooltip template: lang.getText('upload-files'), options: {position: 'top center'},
        a ref: 'file', className: 'action', onClick: @onFileClick,
          Icon name: 'paperclip-lean', size: 20

  renderPost: ->
    if @props.showPost
      Tooltip template: lang.getText('type-rtf'), options: {position: 'top center'},
        a className: cx('action', 'active': @state.post?), onClick: @onNewPostClick,
          Icon name: 'rich-text', size: 20

  renderSnippet: ->
    if @props.showSnippet
      Tooltip template: lang.getText('type-snippet'), options: {position: 'top center'},
        a className: cx('action', 'active': @state.snippet?), onClick: @onSnippetEditorClick,
          Icon name: 'pre', size: 20

  renderMarkdown: ->
    if @props.showMarkdown
      Tooltip template: 'Markdown', options: {position: 'top center'},
        a className: cx('action', 'active': @props.activeMarkdown), onClick: @onMarkdownClick,
          Icon name: 'markdown-solid', size: 22

  render: ->
    div ref: 'root', className: 'message-controls flex-horiz flex-vcenter',
      @renderAt()
      @renderEmoji()
      @renderFile()
      @renderPost()
      @renderSnippet()
      @renderMarkdown()

      if @props.showEmoji
        @renderEmojiTable()
      if @props.showPost
        @renderPostEditor()
      if @props.showSnippet
        @renderSnippetEditor()
