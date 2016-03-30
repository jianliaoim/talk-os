cx    = require 'classnames'
React = require 'react'
ReactDOM = require 'react-dom'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
DSL = require 'talk-msg-dsl'

query = require '../query'
lang      = require '../locales/lang'

dom = require '../util/dom'
type = require '../util/type'
detect = require '../util/detect'
analytics = require '../util/analytics'

LightModalBeta = React.createFactory require '../module/light-modal'
LightModal   = React.createFactory require '../module/light-modal'
LightPopover = React.createFactory require '../module/light-popover'

favoriteActions = require '../actions/favorite'
messageActions = require '../actions/message'

LinkViewer    = React.createFactory require '../app/link-viewer'
MemberCard    = React.createFactory require '../app/member-card'
PostViewer    = React.createFactory require '../app/post-viewer'
QuoteViewer   = React.createFactory require '../app/quote-viewer'
SnippetViewer = React.createFactory require '../app/snippet-viewer'

a    = React.createFactory 'a'
div  = React.createFactory 'div'
span = React.createFactory 'span'

l = lang.getText

module.exports =
  componentDidMount: ->
    @_nameEl = @refs.author

  getInitialState: ->
    showPostViewer: false
    showFile: false
    showProfile: false
    showQuoteViewer: false
    showLinkViewer: false
    showSnippetViewer: false

  # methods

  getAuthorName: ->
    if detect.isTalkai(@props.message.get('creator'))
      l('ai-robot')
    else
      @props.message.get('authorName') or @props.message.getIn(['creator', 'name']) or l('someone')

  getMessageReceiptData: ->
    if @props.isFavorite
      class: {}
      props: {}
    else
      _userId = query.userId(recorder.getState())
      mentions = @props.message.get('mentions')
      receiptors = @props.message.get('receiptors')
      mentionedMe = mentions?.includes _userId
      hasRead = receiptors?.includes _userId

      messageReceiptClass = cx
        'is-unread': mentionedMe and not hasRead
        'is-read': mentionedMe and hasRead

      messageReceiptProps =
        'data-message-id': @props.message.get('_id')
        'onMouseEnter': @sendReceiptAction if mentionedMe and not hasRead

      class: messageReceiptClass
      props: messageReceiptProps

  # showProfile

  getBaseArea: ->
    if @_nameEl?
      @_nameEl.getBoundingClientRect()
    else
      {}

  positionAlgorithm: (baseArea) ->
    # card height is approximately 160
    if baseArea.top > 160
      bottom: "#{window.innerHeight - baseArea.top + 8}px"
      left: "#{baseArea.left}px"
    else
      top: '10px'
      left: "#{baseArea.left}px"

  onAuthorClick: (event) ->
    _userId = query.userId(recorder.getState())
    return if @props.message.get('_creatorId') is _userId
    return if @props.message.get('_toId')
    event.stopPropagation()
    @setState showProfile: (not @state.showProfile)
    analytics.clickChatFromRoom()

  onAuthorClose: ->
    @setState showProfile: false

  sendReceiptAction: ->
    _userId = query.userId(recorder.getState())
    messageActions.receipt @props.message, _userId

  renderMemberCard: ->
    showCard = @state.showProfile and @props.message.get('creator')?
    LightPopover
      onPopoverClose: @onAuthorClose
      baseArea: if showCard then @getBaseArea() else {}
      showClose: false, positionAlgorithm: @positionAlgorithm
      show: showCard
      name: 'member-card'
      MemberCard
        member: @props.message.get('creator')
        _contactId: @props.message.get('_creatorId')
        _teamId: @props.message.get('_teamId')

  # showPostViewer

  onPostViewerShow: (event) ->
    @setState showPostViewer: true
    analytics.viewPost()

  onPostViewerClose: ->
    @setState showPostViewer: false

  renderPostViewer: ->
    LightModal name: 'post-viewer', onCloseClick: @onPostViewerClose, showClose: true, show: @state.showPostViewer,
      PostViewer message: @props.message, onClose: @onPostViewerClose, isFavorite: @props.isFavorite, canEdit: @props.canEdit

  # quote
  onQuoteRedirect: (url) ->
    window.open(url)

  onQuoteViewerShow: -> @setState showQuoteViewer: true
  onQuoteViewerClose: -> @setState showQuoteViewer: false

  renderQuoteViewer: ->
    LightModalBeta name: 'quote-viewer', onCloseClick: @onQuoteViewerClose, showClose: true, show: @state.showQuoteViewer,
      QuoteViewer message: @props.message, onClose: @onQuoteViewerClose, canEdit: @props.canEdit, isFavorite: @props.isFavorite
  # link

  onLinkViewerShow: -> @setState showLinkViewer: true
  onLinkViewerHide: -> @setState showLinkViewer: false

  renderLinkViewer: ->
    LightModalBeta name: 'link-viewer', onCloseClick: @onLinkViewerHide, showClose: true, show: @state.showLinkViewer,
      LinkViewer message: @props.message, onClose: @onLinkViewerHide

  # snippet

  onSnippetViewerShow: ->
    @setState showSnippetViewer: true
    analytics.viewSnippet()

  onSnippetViewerClose: ->
    @setState showSnippetViewer: false

  renderSnippetViewer: ->
    LightModalBeta name: 'snippet-viewer', show: @state.showSnippetViewer, showClose: true, onCloseClick: @onSnippetViewerClose,
      SnippetViewer isFavorite: @props.isFavorite, canEdit: @props.canEdit, message: @props.message, onClose: @onSnippetViewerClose
