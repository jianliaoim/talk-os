cx = require 'classnames'
React = require 'react'
debounce = require 'debounce'
Immutable = require 'immutable'

lang = require '../locales/lang'

draftActions = require '../actions/draft'
notifyActions = require '../actions/notify'

lazyModules = require '../util/lazy-modules'
snippetUtil = require '../util/snippet'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, span, input, button } = React.DOM
T = React.PropTypes

# Await variables
isLoadedCodeEditor = false

module.exports = React.createClass
  displayName: 'snippet-editor'
  mixins: [ PureRenderMixin ]

  propTypes:
    _toId: T.string
    _roomId: T.string
    _teamId: T.string
    _storyId: T.string
    draftMode: T.bool
    onClose: T.func.isRequired
    onSubmit: T.func.isRequired
    attachment: T.object

  getInitialState: ->
    data: Immutable.fromJS
      text: @props.attachment?.text or ''
      title: @props.attachment?.title or ''
      codeType: @props.attachment?.codeType or 'txt'

  componentDidMount: ->
    lazyModules.ensureCodeEditor =>
      isLoadedCodeEditor = true
      @debounceSaveDraft = debounce @saveDraft, 500
      @forceUpdate()

  componentWillUnmount: ->
    @debounceSaveDraft = null

  saveDraft: (snippetDraft) ->
    _channelId = @props._roomId or @props._toId or @props._storyId
    hasDraft = @state.data.get('text').length or @state.data.get('title').length

    if _channelId?
      if hasDraft
        draftActions.saveSnippet @props._teamId, _channelId, snippetDraft.toJS()
      else
        draftActions.clearSnippet @props._teamId, _channelId

  saveState: (data) ->
    @setState
      data: data
    , =>
      @debounceSaveDraft data

  handleEditorChange: (text) ->
    data = @state.data.set 'text', text
    @saveState data

  handleSelectorChange: (codeType) ->
    data = @state.data.set 'codeType', codeType
    @saveState data

  handleTitleChange: (event) ->
    data = @state.data.set 'title', event.target.value
    @saveState data

  onSubmit: ->
    isEmpty = @state.data.get('text')?.trim().length is 0

    if isEmpty
      notifyActions.error lang.getText 'snippet-send-empty'
      return

    @props.onSubmit @state.data.toJS()

  renderCodeEditor: ->
    codeEditor = lazyModules.load 'code-editor'

    codeEditor
      text: @state.data.get 'text'
      codeType: snippetUtil.getCodemirror @state.data.get 'codeType'
      onChange: @handleEditorChange
      placeholder: lang.getText 'snippet-editor-placeholder'

  renderSelector: ->
    snippetSelector = lazyModules.load 'snippet-selector'

    snippetSelector
      onClick: @handleSelectorChange
      codeType: @state.data.get 'codeType'
      codeAssets: snippetUtil.getAssets()

  renderTitle: ->
    div className: 'title',
      input
        type: 'text', className: 'input'
        onChange: @handleTitleChange
        placeholder: lang.getText 'snippet-editor-title-placeholder'
        defaultValue: @state.data.get 'title'

  render: ->
    return null if not isLoadedCodeEditor

    isEmpty = @state.data.get('text')?.trim().length is 0
    buttonClassName = cx 'button',
      'is-primary': not isEmpty
      'is-disabled': isEmpty

    div className: 'snippet-editor', onClick: @onClick,
      div className: 'header line',
        lang.getText 'snippet-editor'
        span className: 'icon icon-remove', onClick: @props.onClose
      div className: 'body',
        @renderTitle()
        @renderCodeEditor()
      div ref: 'footer', className: 'footer',
        @renderSelector()
        div className: 'buttons line',
          button className: buttonClassName, onClick: @onSubmit, disabled: isEmpty,
            if @props.draftMode
              lang.getText 'send'
            else
              lang.getText 'save'
