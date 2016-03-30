cx    = require 'classnames'
React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
config = require '../config'
lang         = require '../locales/lang'

favoriteActions = require '../actions/favorite'
messageActions  = require '../actions/message'
notifyActions   = require '../actions/notify'
deviceActions   = require '../actions/device'

mixinSubscribe = require '../mixin/subscribe'

lookup = require '../util/lookup'
detect = require '../util/detect'
analytics = require '../util/analytics'

Icon = React.createFactory require '../module/icon'
LightMenu   = React.createFactory require '../module/light-menu'
ForwardMenu = React.createFactory require './forward-menu'
ForwardTeam = React.createFactory require './forward-team'

LightDialog = React.createFactory require '../module/light-dialog'
LightModal  = React.createFactory require '../module/light-modal'
LightPopover = React.createFactory require '../module/light-popover'
SlimModal  = React.createFactory require './slim-modal'

MessageEditor = React.createFactory require '../app/message-editor'
PostEditor    = React.createFactory require '../app/post-editor'
SnippetEditor = React.createFactory require '../app/snippet-editor'
TagDropdown   = React.createFactory require '../app/tag-dropdown'
MessageReceiptStatus = React.createFactory require '../app/message-receipt-status'

a = React.createFactory 'a'
div = React.createFactory 'div'
span = React.createFactory 'span'
input = React.createFactory 'input'

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-toolbar'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    hideMenu: T.bool
    showTrash: T.bool
    showInline: T.bool
    showForward: T.bool
    message: T.object.isRequired
    attachmentIndex: T.number

  getDefaultProps: ->
    hideMenu: false
    showTrash: false
    showForward: false
    attachmentIndex: 0

  getInitialState: ->
    baseArea: {} # cache baseArea to bypass unpredictable menu position
    contacts: @getContacts()
    showDeleter: false
    showMessageEditor: false
    showRTFEditor: false
    showSnippetEditor: false
    showTagDropdown: false
    showForwardModal: false
    showLightMenu: false
    forwardTeamId: @props.message.get('_teamId')
    favorites: @getFavorites()

  componentDidMount: ->
    @_tagEl = @refs.tag
    @subscribe recorder, =>
      @setState
        contacts: @getContacts()
        favorites: @getFavorites()

  getFavorites: ->
    query.favoritesBy(recorder.getState(), @props.message.get('_teamId')) or Immutable.List()

  getContacts: ->
    query.contactsBy(recorder.getState(), @props.message.get('_teamId')) or Immutable.List()

  getQuitContact: ->
    query.leftContactsByOne(recorder.getState(), @props.message.get('_teamId'), @props.message.getIn(['creator', '_id']))

  # methods

  isAdmin: ->
    _userId = query.userId(recorder.getState())
    contact = @state.contacts.find (contact) ->
      contact.get('_id') is _userId
    unless contact?
      return false
    return (contact.get('role') in ['admin', 'owner'])

  isCreator: ->
    _userId = query.userId(recorder.getState())
    @props.message.getIn(['creator', '_id']) is _userId

  getBaseArea: ->
    if @_tagEl?
      @_tagEl.getBoundingClientRect()
    else
      {}

  positionAlgorithm: (area) ->
    marginToTags = 6
    if (area.left + 240) > window.innerWidth
      left = area.left - 220
    else
      left = area.left
    if (area.top + 320) > window.innerHeight
      left: area.left - 224
      bottom: window.innerHeight - area.top + marginToTags
    else
      left: area.left - 224
      top: area.bottom + marginToTags

  isFile: ->
    @props.message.getIn(['attachments', @props.attachmentIndex, 'category']) is 'file'

  isRTF: ->
    @props.message.getIn(['attachments', @props.attachmentIndex, 'category']) is 'rtf'

  isSnippet: ->
    @props.message.getIn(['attachments', @props.attachmentIndex, 'category']) is 'snippet'

  hasBody: ->
    @props.message.get('body')?.length > 0

  isAttachmentEditable: ->
    @isCreator() and (@isRTF() or @isSnippet())

  isMessageEditable: ->
    @isCreator() and (@hasBody() or @isRTF() or @isSnippet())

  canDelete: ->
    @isCreator() or @isAdmin()

  isFavorited: ->
    @state.favorites.some (favorite) =>
      favorite.get('_messageId') is @props.message.get('_id')

  getFavoriteId: ->
    @state.favorites
    .find (favorite) =>
      favorite.get('_messageId') is @props.message.get('_id')
    .get('_id')

  # events

  onFavoriteClick: ->
    if @isFavorited()
      favoriteActions.removeFavorite @getFavoriteId()
    else
      favoriteActions.createFavorite @props.message

  onDelete: ->
    @setState showDeleter: true

  onDeleterClose: -> @setState showDeleter: false

  onConfirmDelete: ->
    @setState showDeleter: false
    messageActions.messageDelete @props.message

  onTagClick: (event) ->
    return if @getQuitContact()?
    event.stopPropagation()

    newState =
      showTagDropdown: not @state.showTagDropdown
      baseArea: @getBaseArea()

    if @state.showLightMenu
      newState.showLightMenu = false

    @setState newState

  onEditAttachment: ->
    if @props.message.get('attachments').size
      attachment = @props.message.getIn(['attachments', @props.attachmentIndex])
      switch attachment.get('category')
        when 'rtf'
          @setState showRTFEditor: true
        when 'snippet'
          @setState showSnippetEditor: true

  onEditMessage: ->
    if @hasBody()
      deviceActions.setEditMessageId(@props.message.get('_id'))
    else if @props.message.get('attachments').size
      attachment = @props.message.getIn(['attachments', @props.attachmentIndex])
      switch attachment.get('category')
        when 'rtf'
          @setState showRTFEditor: true
        when 'snippet'
          @setState showSnippetEditor: true

  onMessageEditorClose: ->
    @setState showMessageEditor: false

  onMessageEditorSubmit: (data) ->
    @setState showMessageEditor: false
    messageActions.messageUpdate @props.message.get('_id'), body: data
    analytics.editMessage()

  onTagPopoverClose: ->
    @setState showTagDropdown: false, baseArea: {}

  onEditorClose: ->
    @setState showEditor: false

  onRTFEditorClose: ->
    @setState showRTFEditor: false

  onPostEditorSubmit: (content) ->
    _userId = query.userId(recorder.getState())
    data =
      _teamId: @props._teamId
      _toId: @props._toId or undefined
      _roomId: @props._roomId or undefined
      _creatorId: _userId
      attachments: [
        category: 'rtf'
        data:
          text: content.text
          title: content.title
      ]

    messageActions.messageUpdate @props.message.get('_id'), data, =>
      @setState showPostEditor: false

  onRTFEditorSubmit: ({title, text}) ->
    _userId = query.userId(recorder.getState())
    data =
      _teamId: @props._teamId
      _toId: @props._toId or undefined
      _roomId: @props._roomId or undefined
      _creatorId: _userId
      body: ''
      attachments: [
        category: 'rtf',
        data:
          text: text
          title: title
      ]
    messageActions.messageUpdate @props.message.get('_id'), data, =>
      @setState showRTFEditor: false

  onSnippetEditorClose: ->
    @setState showSnippetEditor: false

  onSnippetEditorSubmit: (content) ->
    _userId = query.userId(recorder.getState())
    data =
      _teamId: @props._teamId
      _toId: @props._toId or undefined
      _roomId: @props._roomId or undefined
      _creatorId: _userId
      attachments: [
        category: 'snippet'
        data:
          codeType: content.codeType
          text: content.text
          title: content.title
      ]

    messageActions.messageUpdate @props.message.get('_id'), data, =>
      @setState showSnippetEditor: false

  onForwardClick: ->
    @setState showForwardModal: 'forward-menu'

  onForwardClose: ->
    @setState
      showForwardModal: false
      forwardTeamId: @props.message.get('_teamId')

  onTeamSwitchClick: ->
    @setState showForwardModal: 'team-list'

  onTeamSwitch: (_teamId) ->
    @setState
      forwardTeamId: _teamId
      showForwardModal: 'forward-menu'

  onMenuToggle: ->
    newState =
      showLightMenu: not @state.showLightMenu

    if @state.showTagDropdown
      newState.showTagDropdown = false

    @setState newState

  onDownload: ->
    # download via url, track event only
    analytics.downloadFile()

  renderActions: ->
    LightMenu
      onMenuToggle: @onMenuToggle
      open: @state.showLightMenu
      hint: Icon name: 'ellipsis-vertical', size: 16
      if not config.isGuest
        div className: 'item line', onClick: @onFavoriteClick,
          Icon name: 'star', size: 16
          if @isFavorited() then l('cancel-favorite') else l('favorite')
      if @isFile()
        url = @props.message.getIn(['attachments', @props.attachmentIndex, 'data', 'downloadUrl'])
        a className: 'item line', href: url, onClick: @onDownload,
          Icon name: 'download', size: 16
          l('download')
      if @isMessageEditable()
        div className: 'item line', onClick: @onEditMessage,
          Icon name: 'edit', size: 16
          l('edit')
      if not config.isGuest
        div className: 'item line', onClick: @onForwardClick,
          Icon name: 'share', size: 16
          l('forward')
      if @canDelete()
        div className: 'item line', onClick: @onDelete,
          Icon name: 'trash', size: 16
          l('delete')

  renderActionsInline: ->
    isQuit = @getQuitContact()
    tagClassName = cx 'ti', 'ti-tag', 'muted', 'is-active': @state.showTagDropdown

    cxStar = cx 'is-star', 'is-active': @isFavorited()

    div className: 'toolbar',
      if @isFile()
        a className: 'line', href: @props.message.getIn(['attachments', @props.attachmentIndex, 'data', 'downloadUrl']),
          Icon name: 'download', size: 18
      if (not config.isGuest) and (not isQuit)
        span ref: 'tag', className: tagClassName, onClick: @onTagClick
      if not config.isGuest
        Icon name: (if @isFavorited() then 'star-solid' else 'star'), size: 18, className: cxStar, onClick: @onFavoriteClick
      if @isAttachmentEditable()
        Icon name: 'edit', size: 18, onClick: @onEditAttachment
      if not config.isGuest
        Icon name: 'share', size: 18, onClick: @onForwardClick
      if @props.showTrash and @canDelete()
        Icon name: 'trash', size: 18, onClick: @onDelete

  renderDeleter: ->
    LightDialog
      name: 'message-delete'
      confirm: lang.getText('confirm')
      cancel: lang.getText('cancel')
      content: lang.getText('message-deleter-confirm')
      flexible: true
      onCloseClick: @onDeleterClose
      onConfirm: @onConfirmDelete
      show: @state.showDeleter

  renderMessageEditor: ->
    LightModal
      name: 'message-editor'
      title: lang.getText('message-editor-title')
      onCloseClick: @onMessageEditorClose
      showClose: false
      show: @state.showMessageEditor
      MessageEditor
        topicId: @props.message.get('_roomId')
        onSubmit: @onMessageEditorSubmit
        showButton: true
        showActions: false
        message: @props.message
        _teamId: @props.message.get('_teamId')
        _roomId: @props.message.get('_roomId')

  renderRTFEditor: ->
    return if not @props.message.get('attachments').size
    target = @props.message.get('attachments').filter (attachment) ->
      attachment.get('category') is 'rtf'
    return if not target.size
    rtf = target.getIn([0, 'data'])

    LightModal name: 'post-editor', onCloseClick: @onRTFEditorClose, showClose: false, show: @state.showRTFEditor,
      PostEditor
        _channelId: lookup.getMessageChannelId(@props.message)
        _teamId: @props.message.get('_teamId')
        title: rtf.get('title')
        text: rtf.get('text')
        onClose: @onRTFEditorClose
        onSubmit: @onRTFEditorSubmit, draftMode: false

  renderSnippetEditor: ->
    return if not @props.message.get('attachments').size
    target = @props.message.get('attachments').filter (attachment) ->
      attachment.get('category') is 'snippet'
    return if not target.size
    snippet = target.getIn([0, 'data'])

    LightModal
      name: 'snippet-editor'
      show: @state.showSnippetEditor
      showClose: false
      onCloseClick: @onSnippetEditorClose,
        SnippetEditor
          _toId: @props.message.get '_toId'
          _roomId: @props.message.get '_roomId'
          _teamId: @props.message.get '_teamId'
          _storyId: @props.message.get '_storyId'
          onClose: @onSnippetEditorClose
          onSubmit: @onSnippetEditorSubmit
          attachment: snippet.toJS()

  renderTagDropdown: ->
    LightPopover
      name: 'tag-dropdown'
      onPopoverClose: @onTagPopoverClose
      positionAlgorithm: @positionAlgorithm
      baseArea: @state.baseArea
      showClose: false
      show: @state.showTagDropdown
      TagDropdown
        tags: @props.message.get('tags') or Immutable.List(), _messageId: @props.message.get('_id')
        _teamId: @props.message.get('_teamId')

  renderForwardModal: ->
    show = @state.showForwardModal in ['forward-menu', 'team-list']

    props = assign { show: show, onClose: @onForwardClose },
      { name: 'forward-menu', title: l('forward-message') } if @state.showForwardModal is 'forward-menu'
      { name: 'team-list', onBack: @onForwardClick } if @state.showForwardModal is 'team-list'

    SlimModal props,
      switch @state.showForwardModal
        when 'forward-menu' then @renderForwardMenu()
        when 'team-list' then @renderForwardTeamList()

  renderForwardMenu: ->
    _userId = query.userId(recorder.getState())
    ForwardMenu
      _userId: _userId
      _teamId: @state.forwardTeamId
      message: @props.message
      onTeamSwitchClick: @onTeamSwitchClick
      onClose: @onForwardClose

  renderForwardTeamList: ->
    _teamId = @props.message.get('_teamId')
    ForwardTeam
      _teamId: @state.forwardTeamId
      onTeamSwitch: @onTeamSwitch

  render: ->
    return null if detect.isMessageFake(@props.message)

    _userId = query.userId(recorder.getState())
    byMe = @props.message.getIn(['creator', '_id']) is _userId

    return null if config.isGuest and not byMe

    className = cx 'message-toolbar',
      'line': @props.showInline
      'is-inline': @props.showInline
      'is-active': @state.showTagDropdown or @state.showLightMenu
      'is-quit': @getQuitContact()?

    tagClassName = cx 'ti', 'ti-tag', 'is-tag', 'muted', 'is-active': @state.showTagDropdown
    div className: className,
      if not config.isGuest
        MessageReceiptStatus
          message: @props.message
      if (not config.isGuest) and (not @props.showInline) and (not @props.showForward)
        span ref: 'tag', className: tagClassName, onClick: @onTagClick
      if (not config.isGuest) and @props.showForward and not @props.showInline
        Icon name: 'share', size: 18, onClick: @onForwardClick
      if not @props.hideMenu
        @renderActions()
      if @props.showInline
        @renderActionsInline()
      @renderMessageEditor()
      @renderDeleter()
      @renderRTFEditor()
      @renderSnippetEditor()
      @renderTagDropdown()
      @renderForwardModal()
