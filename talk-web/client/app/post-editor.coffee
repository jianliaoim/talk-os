cx = require 'classnames'
React = require 'react'
debounce = require 'debounce'
ReactDOM = require 'react-dom'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
config = require '../config'
handlers = require '../handlers'

prefsAction = require '../actions/prefs'
draftActions = require '../actions/draft'
notifyActions = require '../actions/notify'

lang = require '../locales/lang'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'
mixinSelectEmoji = require '../mixin/select-emoji'
mixinSuggestText = require '../mixin/suggest-text'

time = require '../util/time'
detect = require '../util/detect'
keyboard = require '../util/keyboard'
analytics = require '../util/analytics'
selection = require '../util/selection'
uploadUtil  = require '../util/upload'
lazyModules = require '../util/lazy-modules'

EmojiTable = React.createFactory require './emoji-table'
MentionMenu = React.createFactory require './mention-menu'

Icon = React.createFactory require '../module/icon'

LitePopover = React.createFactory require 'react-lite-layered/lib/popover'

{ a, li, ul, div, span, input, button } = React.DOM
T = React.PropTypes

MAX_WIDTH = 800 - 15 * 2

module.exports = React.createClass
  displayName: 'post-editor'
  mixins: [mixinSubscribe, mixinSuggestText, mixinSelectEmoji, mixinQuery, PureRenderMixin]

  propTypes:
    _teamId:    T.string
    _channelId: T.string
    _channelType: T.string
    title:      T.string
    text:       T.string.isRequired
    onClose:    T.func.isRequired
    onSubmit:   T.func.isRequired
    draftMode:  T.bool.isRequired

  getInitialState: ->
    isHover: false
    text: @props.text or ''
    title: @props.title or ''

  componentDidMount: ->
    # https://github.com/petehunt/webpack-howto#9-async-loading
    requireStartTime = (new Date).valueOf()
    require.ensure [], =>
      lazyModules.define 'rangy', (require 'rangy')
      lazyModules.define 'simditor', (require 'simditor')
      analytics.compareRequireCost requireStartTime, 'post-editor'

      @simditor = @loadSimditor()
      @_textArea = document.querySelector('.simditor-body')
      @initCustomToolbar()

      @debouncedSaveDraft = debounce @saveDraft, 500

      # init Drop and Paste uploading
      @initFileDropHandler()

  componentWillUnmount: ->
    ReactDOM.unmountComponentAtNode @_customToolbarEl
    @simditor?.destroy()

  # methods

  appendElem: (node, startPoint, addSpace) ->
    #insert element node
    #@_range is updated on every selection change
    range = @_range.cloneRange()
    if startPoint?
      range.setStart startPoint.node, startPoint.offset-1
      range.deleteContents()
    @simditor.selection.insertNode node, @_range
    if addSpace
      spaceElem = document.createElement 'span'
      spaceElem.innerHTML = '&nbsp;'
      @simditor.selection.insertNode spaceElem
    @onChange()

  trackStartPoint: ->
    if @simditor.selection._range?
      {startContainer, startOffset} = @simditor.selection._range
      {node: startContainer, offset: startOffset}

  getTextUntilCaret: ->
    if @simditor.selection._range?
      range = @simditor.selection._range.cloneRange()
      range.setStart range.startContainer, 0
      range.toString()

  getUploadProps: ->
    multiple: true
    accept: '.gif,.jpg,.jpeg,.bmp,.png'
    onFileHover: @onIsHover
    onSuccess: @onImageUpload
    onError: handlers.fileError

  positionMention: (baseArea) ->
    if baseArea.y2 + 300 > window.innerHeight
      left: "#{baseArea.x}px"
      bottom: "#{window.innerHeight - baseArea.y}px"
    else
      left: "#{baseArea.x}px"
      top: "#{baseArea.y2}px"

  positionEmoji: (baseArea) ->
    left: "#{baseArea.x}px"
    top: "#{baseArea.y2}px"

  getEmojiTableBaseArea: ->
    if @_toolbarEl?
      @_toolbarEl.getBoundingClientRect()
    else
      {}

  customPositionEmojiTable: (baseArea) ->
    top: "#{baseArea.bottom}px"
    left: "#{baseArea.left}px"

  loadSimditor: ->
    Simditor = lazyModules.load('simditor')
    simditor = new Simditor
      toolbar: [
        'title', 'bold', 'italic', 'underline', 'strikethrough',  '|'
        'ol', 'ul', 'blockquote', 'code', 'indent', 'outdent', 'alignment', '|'
        'link', 'hr', 'table'
      ]
      textarea: @refs.text
      placeholder: lang.getText 'rich-text-editor-placeholder'
      toolbarFloat: false
      allowedAttributes:
        img: [
          'src', 'alt', 'width', 'height', 'data-non-image', 'role'
        ]

    simditor.setValue @state.text
    @_range = simditor.selection._range
    simditor.on 'valuechanged', => @onChange()
    simditor.on 'keydown', (e) => @onKeypress(e)
    simditor.on 'selectionchanged', =>  @onSelectionChange()
    simditor.focus()
    window.simditor = simditor
    simditor

  initCustomToolbar: ->
    toolbar = document.querySelector '.simditor > .simditor-wrapper > .simditor-toolbar'
    @_toolbarEl = toolbar

    node = document.createElement 'span'
    node.className = 'custom-toolbar'
    toolbar.insertBefore(node, toolbar.firstChild)
    ReactDOM.render @renderInjection(), node
    @_customToolbarEl = node

  getIsEmpty: ->
    not (@state.text? and @state.text.length > 0)

  saveDraft: (data) ->
    if @props.draftMode
      _channelId = @props._channelId
      hasDraft = @state.text.length or @state.title.length

      if hasDraft
        draftActions.savePost @props._teamId, _channelId, data
      else
        draftActions.clearPost @props._teamId, _channelId

  initFileDropHandler: ->
    dropTarget = @refs.root
    uploadUtil.handleFileDropping dropTarget, @getUploadProps()

  # events

  onClose: ->
    @props.onClose
      text: @state.text
      title: @state.title

  onChange: ->
    data = @simditor.getValue()
    @debouncedSaveDraft(title: @state.title, text: data)
    @setState text: data

  onSelectionChange: ->
    @_range = @simditor.selection._range
    @customDetectMention()

  onKeypress: (event) ->
    if (event.keyCode is keyboard.slash)
      event.stopPropagation()
    else if @state.showMentionMenu or @state.showEmojiMenu
      if event.keyCode in [keyboard.enter, keyboard.up, keyboard.down]
        event.preventDefault()

  onSubmit: ->
    unless @state.text.trim().length>0
      notifyActions.error lang.getText('fail-send-empty')
    else
      @props.onSubmit
        title: @state.title
        text: @state.text

  onTitleChange: (event) ->
    title = event.target.value
    @saveDraft title: title, text: @state.text
    @setState title: title

  onEmojiSelect: (emoji) ->
    @appendElem selection.getEmojiNode(emoji)
    @setState showEmojiTable: false

  onImageUpload: ({fileData}) ->
    imageWidth = fileData.imageWidth
    imageHeight = fileData.imageHeight
    if imageWidth >= MAX_WIDTH
      height = Math.round imageHeight/(imageWidth/MAX_WIDTH)
      imgSrc =  fileData.thumbnailUrl.replace('h/200', "h/#{height}").replace('w/200', "w/#{MAX_WIDTH}")
    else
      imgSrc =  fileData.thumbnailUrl.replace('h/200', "h/#{imageHeight}").replace('w/200', "w/#{imageWidth}")
    @appendElem selection.getImageNode(imgSrc)

  onCustomMentionClick: ->
    node = document.createTextNode '@'
    @appendElem node

  onIsHover: (isHover) ->
    if @state.isHover isnt isHover
      @setState isHover: isHover

  onPaste: (event) ->
    uploadUtil.handlePasteEvent event.nativeEvent, @getUploadProps()

  onFileClick: ->
    uploadUtil.handleClick @getUploadProps()

  customDetectMention: ->
    text = @getTextUntilCaret()
    return unless text?
    name = text.split('@')[1..].reverse()[0]
    if name is '' then @_atSel = @trackStartPoint()
    @filterMembers name

  onCustomMentionSelect: (data) ->
    @setState showMentionMenu: false
    prefs = query.contactPrefsBy(recorder.getState(), @props._teamId, data.get('_id'))
    name = prefs?.get('alias') or data.get('name')
    mention = document.createElement 'mention'
    mention.setAttribute 'data-id', data.get('_id')
    mention.innerHTML = "@#{name}"
    @appendElem mention, @_atSel , true

  customDetectEmoji: ->
    text = @getTextUntilCaret()
    name = text.split(':')[1..].reverse()[0]
    if name is '' then @_colonSel = @trackStartPoint()
    @filterEmojis name

  onEmojiMenuSelect: (emoji) ->
    @setState showEmojiMenu: false
    emojiImg = document.createElement 'img'
    emojiImg.src = "https://dn-talk.oss.aliyuncs.com/icons/emoji/#{emoji}.png"
    emojiImg.setAttribute 'role', 'emoji'
    @appendElem emojiImg, @_colonSel

  # renderers

  renderCustomMentionMenu: (hasMentionMenu) ->
    LitePopover
      name: 'mention'
      showClose: false
      baseArea: if hasMentionMenu then @getMentionBaseArea() else {}
      onPopoverClose: @onMentionMenuClose
      positionAlgorithm: @positionMention
      show: hasMentionMenu
      MentionMenu
        onSelect: @onCustomMentionSelect
        members: @state.suggestMembers
        contacts: @state.suggestContacts
        _teamId: @props._teamId

  renderCustomEmojiTable: ->
    LitePopover
      name: 'emoji-table'
      showClose: false
      baseArea: if @state.showEmojiTable then @getEmojiTableBaseArea() else {}
      onPopoverClose: @onEmojiTableClose
      positionAlgorithm: @customPositionEmojiTable
      show: @state.showEmojiTable
      EmojiTable onSelect: @onEmojiSelect

  renderEditable: ->
    div className: 'rich-text', tabInbox: 0, onPaste: @onPaste,
      div ref: 'text'
      if @state.isHover
        div className: 'uploader-cover'

  renderTitle: ->
    div className: 'title',
      input
        type: 'text'
        value: @state.title
        onChange: @onTitleChange
        className: 'input'
        placeholder: lang.getText 'post-editor-title-placeholder'

  renderInjection: ->
    ul {},
      li {},
        a className: 'toolbar-item toolbar-item-bold', onClick: @onEmojiTableClick,
          Icon type: 'icon', name: 'emoji', size: 16
      li {},
        a className: 'toolbar-item toolbar-item-bold', onClick: @onCustomMentionClick,
          Icon type: 'icon', name: 'at', size: 16
      li {},
        a className: 'toolbar-item toolbar-item-bold', onClick: @onFileClick,
          Icon type: 'icon', name: 'image', size: 14
      li {},
        span className: 'separator'

  render: ->
    clsSubmit = cx
      'button': true
      'is-primary': not @getIsEmpty()
      'is-disabled': @getIsEmpty()

    hasMentionMenu = @state.showMentionMenu
    hasEmojiMenu = @state.showEmojiMenu

    div ref: 'root', className: 'post-editor',
      div className: 'header line',
        lang.getText 'rich-text-editor'
        span className: 'icon icon-remove', onClick: @onClose
      @renderTitle()
      @renderEditable()
      div className: 'footer',
        div className: 'buttons line',
          button className: clsSubmit, onClick: @onSubmit, disabled: @getIsEmpty(),
            if @props.draftMode then lang.getText('send') else lang.getText('save')
      @renderCustomMentionMenu(hasMentionMenu)
      @renderEmojiMenu(hasEmojiMenu)
      @renderCustomEmojiTable()
