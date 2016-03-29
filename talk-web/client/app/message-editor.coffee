cx = require 'classnames'
DSL = require 'talk-msg-dsl'
React = require 'react'
keycode = require 'keycode'
debounce = require 'debounce'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
uploadUtil  = require '../util/upload'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'
settingsActions = require '../actions/settings'

eventBus = require '../event-bus'
query = require '../query'
config = require '../config'
handlers = require '../handlers'

draftActions = require '../actions/draft'
notifyActions = require '../actions/notify'
deviceActions = require '../actions/device'
notifyBannerActions = require '../actions/notify-banner'

lang = require '../locales/lang'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'
mixinSuggestTextbox = require '../mixin/suggest-textbox'

time = require '../util/time'
type = require '../util/type'
detect = require '../util/detect'
keyboard = require '../util/keyboard'
assemble = require '../util/assemble'
selection = require '../util/selection'
textareaUtil = require '../util/textarea'

Textarea = React.createFactory require 'react-textarea-autosize'
MessageControls = React.createFactory require './message-controls'
EnterHintClass = require './enter-hint'
EnterHint = React.createFactory EnterHintClass

{ kbd, div, span, button } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-editor'
  mixins: [mixinSubscribe, mixinSuggestTextbox, mixinQuery, LinkedStateMixin, PureRenderMixin]

  propTypes:
    _toId: T.string
    _roomId: T.string
    _teamId: T.string
    _storyId: T.string
    _channelId: T.string
    _channelType: T.string
    message: T.instanceOf(Immutable.Map)
    onSubmit: T.func.isRequired
    isEditMode: T.bool
    enterMethod: T.string

  getInitialState: ->
    text = @drawDraft @props

    # returns an object
    end: text.length
    text: text
    start: text.length
    activeMarkdown: @getMarkdownStatus()
    enterMethod: @getEnterMethod()
    isEditMode: false

  componentDidMount: ->
    unless detect.isIPad()
      @focusToBox()
      @setSelection()
    @debounceSaveDraft = debounce @saveDraft, 500
    @debounceClearDraft = debounce @clearDraft, 500
    eventBus.addListener 'dirty-action/focus-box', @focusToBox

    @subscribe recorder, =>
      @setState
        activeMarkdown: @getMarkdownStatus()
        enterMethod: @getEnterMethod()

  componentWillUnmount: ->
    eventBus.removeListener 'dirty-action/focus-box', @focusToBox

  componentWillReceiveProps: (props) ->
    if @props._channelId isnt props._channelId
      text = @drawDraft props

      @setState
        end: text.length
        text: text
        start: text.length

  drawDraft: (props) ->
    if props.message.has('body') and props.message.get('body').length > 0
      draft = props.message.get 'body'
      DSL.flattern (DSL.update DSL.read draft, @getDslTable())
    else ''

  # methods

  getTextareaEl: ->
    rootEl = @refs.root
    rootEl?.querySelector('textarea')

  getSpecials: ->
    ['@', ':', '#', '/']

  focusToBox: ->
    window.requestAnimationFrame =>
      textareaEl = @getTextareaEl()
      textareaEl?.focus()

  setSelection: ->
    window.requestAnimationFrame =>
      textareaEl = @getTextareaEl()
      textareaEl?.selectionStart = @state.start
      textareaEl?.selectionEnd = @state.end

  submitContent: ->
    return unless @state.text.trim().length > 0

    if @state.text.length > 1000
      notifyActions.warn lang.getText('too-long-text-submit')
    else if query.deviceByOffline(recorder.getState())
      notifyActions.warn lang.getText('send-later')
    else
      @clearInputText()
      displayType = if @state.activeMarkdown then 'markdown' else 'text'
      text = DSL.write @getDslText @state.text
      @props.onSubmit text, displayType

  getDslText: (text) ->
    dslTable = []
    categories = []
    if text.indexOf('@') >= 0
      dslTable = dslTable.concat(@getMentionDslTable())
      categories = categories.concat({category: 'at', view: '@'})
    if text.indexOf('#') >= 0
      dslTable = dslTable.concat(@getTopicDslTable())
      categories = categories.concat({category: 'room', view: '#'})
    DSL.recognize text, categories, dslTable

  getMarkdownStatus: ->
    query.markdownStatus recorder.getState()

  getEnterMethod: ->
    query.enterMethod(recorder.getState()) or EnterHintClass.getEnterMethods().first()

  clearInputText: ->
    @debounceClearDraft @props._teamId, @props._channelId
    @setState text: '', start: 0, end: 0

  clearDraft: (_teamId, _channelId) ->
    return if @props.isEditMode
    draftActions.clearDraft _teamId, _channelId

  saveDraft: (_teamId, _channelId, value) ->
    return if @props.isEditMode
    draftActions.saveDraft _teamId, _channelId, value

  # events

  onEmojiSelect: (emoji) ->
    settingsActions.updateEmojiCounts(emoji)
    newState = textareaUtil.makeInsertState @state.text, @state.start, ":#{emoji}: "
    newState.showEmojiMenu = false
    @setState newState, =>
      @setSelection()
      @focusToBox()

  onEmojiMenuSelect: (emoji) ->
    settingsActions.updateEmojiCounts(emoji)
    newState = textareaUtil.makeCompleteState @state.text, @state.start, ':', ":#{emoji}: "
    newState.showEmojiMenu = false
    @setState newState, @setSelection

  onMentionSelect: (data) ->
    prefs = query.contactPrefsBy(recorder.getState(), @props._teamId, data.get('_id'))
    name = prefs?.get('alias') or data.get('name')
    newState = textareaUtil.makeCompleteState @state.text, @state.start, '@', "@#{name} "
    newState.showMentionMenu = false
    @setState newState, @setSelection

  onTopicSelect: (data) ->
    name = if data.get('isGeneral') then lang.getText('room-general') else data.get('topic')
    newState = textareaUtil.makeCompleteState @state.text, @state.start, '#', "##{name} "
    newState.showTopicMenu = false
    @setState newState, @setSelection

  onCommandMenuSelect: (command) ->
    newState = textareaUtil.makeCompleteState @state.text, @state.start, '/', "#{command.get('trigger')} "
    newState.showCommandMenu = false
    @setState newState, @setSelection

  onMentionClick: ->
    newState = textareaUtil.makeInsertState @state.text, @state.start, '@'
    @setState newState, =>
      @setSelection()
      setTimeout =>
        try
          @getTextareaEl()?.dispatchEvent (new window.Event 'input', bubbles: true)
        catch
          null

  onChange: (event) ->
    text = event.target.value
    selectionStart = @refs.textarea.selectionStart
    selectionEnd = @refs.textarea.selectionEnd

    newState =
      text: text
      showMentionMenu: false
      showEmojiMenu: false
      showTopicMenu: false
      showCommandMenu: false
      start: selectionStart
      end: selectionEnd

    examineText = text.slice(0, selectionStart)
    trigger = textareaUtil.getTrigger(examineText, @getSpecials())

    if trigger is '@'
      result = @filterMembers textareaUtil.getQuery(examineText, '@')
      newState.suggestMembers = result.suggestMembers
      newState.suggestContacts = result.suggestContacts
      newState.showMentionMenu = result.showMentionMenu
    else if trigger is ':'
      result = @filterEmojis textareaUtil.getQuery(examineText, ':')
      newState.suggestEmojis = result.suggestEmojis
      newState.showEmojiMenu = result.showEmojiMenu
    else if trigger is '#'
      result = @filterTopics textareaUtil.getQuery(examineText, '#')
      newState.suggestTopics = result.suggestTopics
      newState.showTopicMenu = result.showTopicMenu
    else if trigger is '/' and text[0] is '/'
      result = @filterCommands textareaUtil.getQuery(examineText, '/')
      newState.suggestCommands = result.suggestCommands
      newState.showCommandMenu = result.showCommandMenu

    @setState newState
    @debounceSaveDraft @props._teamId, @props._channelId, text

  onKeyDown: (event) ->
    if @state.showMentionMenu or @state.showEmojiMenu or @state.showTopicMenu or @state.showCommandMenu
      if event.keyCode in [keyboard.enter, keyboard.up, keyboard.down, keyboard.tab]
        event.preventDefault()
        return

    if event.keyCode is keyboard.enter
      pressedCtrl = event.ctrlKey or event.metaKey
      pressedShift = event.shiftKey
      ctrlEnter =  @state.enterMethod is 'ctrlEnter' and pressedCtrl
      shiftEnter = @state.enterMethod is 'shiftEnter' and pressedShift
      enter = @state.enterMethod is 'enter' and not pressedCtrl and not pressedShift
      if ctrlEnter or shiftEnter or enter
        event.preventDefault()
        @submitContent()

  onPaste: (event) ->
    uploadUtil.handlePasteEvent event.nativeEvent,
      multiple: true
      onCreate: handlers.fileCreate
      onProgress: handlers.fileProgress
      onSuccess: handlers.fileSuccess
      onError: handlers.fileError
      metaData: handlers.file.getNewMessageInfo()

  onEditModeCancel: ->
    deviceActions.setEditMessageId(null)

  onHeightChange: ->
    isTuned = recorder.getState().getIn ['device', 'isTuned']
    if isTuned
      eventBus.emit 'dirty-action/new-message'

  # renderers

  renderEnterHint: ->
    EnterHint
      enterMethod: @state.enterMethod

  renderLeftActions: ->
    MessageControls
      _toId: @props._toId
      _teamId: @props._teamId
      _roomId: @props._roomId
      _storyId: @props._storyId
      _channelId: @props._channelId
      _channelType: @props._channelType
      showAt: false
      showFile: false
      showPost: false
      showSnippet: false
      showMarkdown: false
      showEmoji: true
      onEmojiSelect: @onEmojiSelect

  renderRightActions: ->
    MessageControls
      _toId: @props._toId
      _teamId: @props._teamId
      _roomId: @props._roomId
      _storyId: @props._storyId
      _channelId: @props._channelId
      _channelType: @props._channelType
      showAt: @props._roomId? or @props._storyId?
      showEmoji: false
      activeMarkdown: @state.activeMarkdown
      clearInputText: @clearInputText
      onMentionClick: @onMentionClick

  renderEditModeActions: ->
    div className: 'edit-mode-actions',
      span className: 'inline-button', onClick: @onEditModeCancel, lang.getText('cancel')
      span className: 'inline-button', onClick: @submitContent, lang.getText('save')

  render: ->
    hasMentionMenu = @state.showMentionMenu
    hasEmojiMenu = @state.showEmojiMenu
    hasTopicMenu = @state.showTopicMenu
    hasCommandMenu = @state.showCommandMenu
    hasMenu = hasMentionMenu or hasEmojiMenu or hasTopicMenu or hasCommandMenu

    messageEditorClass = cx 'message-editor', 'flex-static',
      'has-menu': hasMenu
      'is-edit-mode': @props.isEditMode
    div className: messageEditorClass, ref: 'root', tabIndex: 0, onPaste: @onPaste,
      if not @props.isEditMode
        @renderLeftActions()

      Textarea
        ref: 'textarea'
        className: 'lite-textbox'
        value: @state.text
        minRows: 1
        maxRows: 5
        onChange: @onChange
        onClick: @onChange
        onKeyUp: @onChange
        onKeyDown: @onKeyDown
        onHeightChange: @onHeightChange

      if not @props.isEditMode
        @renderRightActions()

      if not @props.isEditMode
        @renderEnterHint()

      if @props.isEditMode
        @renderEditModeActions()

      @renderMentionMenu(hasMentionMenu)
      @renderEmojiMenu(hasEmojiMenu)
      @renderTopicMenu(hasTopicMenu)
      @renderCommandMenu(hasCommandMenu)
