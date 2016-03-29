cx = require 'classnames'
React = require 'react'
debounce = require 'debounce'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

eventBus = require '../event-bus'

lang = require '../locales/lang'

handlers = require '../handlers'
deviceActions = require '../actions/device'
dom = require '../util/dom'

MessageTimeline = React.createFactory require './message-timeline'

LiteLoadingMore = React.createFactory require('react-lite-misc').LoadingMore
LiteLoadingIndicator = React.createFactory require('react-lite-misc').LoadingIndicator

div = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-area'
  mixins: [PureRenderMixin]

  propTypes:
    # for timeline
    _toId: T.string
    _roomId: T.string
    _teamId: T.string
    _storyId: T.string
    end: T.bool.isRequired
    banner: T.node
    routerQuery: T.instanceOf(Immutable.Map)
    unread: T.number.isRequired
    isTuned: T.bool.isRequired
    loading: T.bool.isRequired
    preview: T.bool
    isSearch: T.bool
    messages: T.instanceOf(Immutable.List)
    isPreview: T.bool
    selectedId: T.string
    onUnreadClick: T.func.isRequired
    readMessageId: T.string
    isLoadingAfter: T.bool.isRequired
    isClearingUnread: T.bool
    onScrollReachTop: T.func.isRequired
    isMessageHighlight: T.bool
    onScrollReachBottom: T.func.isRequired

  getDefaultProps: ->
    isSearch: false
    isMessageHighlight: false
    preview: false

  componentDidMount: ->
    @detect = debounce @detect, 300
    @jumpToBottom()
    eventBus.addListener 'dirty-action/new-message', @dirtyScrollToBottom
    eventBus.addListener 'dirty/force-read', @forceRead

  componentWillUnmount: ->
    eventBus.removeListener 'dirty-action/new-message', @dirtyScrollToBottom
    eventBus.removeListener 'dirty/force-read', @forceRead

  onWheel: ->
    @detect() # debouced version

  jumpToBottom: ->
    return if @props.isSearch
    window.requestAnimationFrame =>
      node = @getScrollEl()
      if node
        node.scrollTop = node.scrollHeight

  dirtyScrollToBottom: ->
    return if @props.isSearch
    node = @getScrollEl()
    dom.smoothScrollTo node, 0, node.scrollHeight

  detect: ->
    isScrollAtBottom = @isScrollAtBottom()

    if @isScrollAtTop()
      cachedScrollHeight = @getScrollEl().scrollHeight
      @props.onScrollReachTop =>
        @restoreScrollTop cachedScrollHeight
    else if isScrollAtBottom
      @props.onScrollReachBottom()

    if isScrollAtBottom isnt @props.isTuned
      deviceActions.tuned isScrollAtBottom

    @checkUnreadMentions()

  restoreScrollTop: (cachedScrollHeight) ->
    node = @getScrollEl()
    diff = node.scrollHeight - cachedScrollHeight
    # when diff < 0, scrolling appears to be jumping
    if diff > 0
      node.scrollTop = node.scrollTop + diff

  isScrollAtTop: ->
    node = @getScrollEl()
    node.scrollTop < 20

  isScrollAtBottom: ->
    node = @getScrollEl()
    node.scrollTop + node.clientHeight + 80 > node.scrollHeight

  forceRead: ->
    @onUnreadClick()

  checkUnreadMentions: ->
    handlers.message.checkUnreadMentions()

  getScrollEl: ->
    @refs.scroll

  onUnreadClick: ->
    node = @getScrollEl()
    node.scrollTop = node.scrollHeight
    @props.onUnreadClick()

  renderUnreadTip: ->
    return null if @props.isClearingUnread or @props.unread is 0
    div onClick: @onUnreadClick,
      span className: 'unread-tip line',
        span className: 'icon icon-chevron-down'
        lang.getText('%s-new-messages').replace('%s', @props.unread)

  renderTimeline: ->
    MessageTimeline
      _toId: @props._toId
      _roomId: @props._roomId
      _teamId: @props._teamId
      _storyId: @props._storyId
      messages: @props.messages
      unread: @props.unread
      readMessageId: @props.readMessageId
      selectedId: @props.routerQuery.get('search')
      isMessageHighlight: @props.isMessageHighlight
      preview: @props.preview

  render: ->
    messageAreaClass = cx 'message-area flex-space', 'is-preview': @props.preview

    div className: messageAreaClass,
      div className: 'scroller thin-scroll', ref: 'scroll', onWheel: @onWheel,
        @props.banner
        # 不显示 "历史已经全部加载", 故传入空字符串
        LiteLoadingMore
          end: @props.end, show: @props.loading, endLocale: ''
        @renderTimeline()
        if @props.isLoadingAfter
          LiteLoadingIndicator()
      @renderUnreadTip()
