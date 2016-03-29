cx = require 'classnames'
React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

mentionedMessageActions = require '../actions/mentioned-message'

routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

mixinQuery = require '../mixin/query'
mixinFinder = require '../mixin/finder-mixin'
mixinRouter = require '../mixin/router'
mixinSubscribe = require '../mixin/subscribe'

MessageRich = React.createFactory require './message-rich'
FileQueueMentions = React.createFactory require './file-queue-mentions'

Icon = React.createFactory require '../module/icon'
UserName = React.createFactory require '../module/user-name'
NoMentions = React.createFactory require '../module/no-mentions'

LiteModal = React.createFactory require('react-lite-layered').Modal
LiteWheeling = React.createFactory require('react-lite-misc').Wheeling
LiteLoadingMore = React.createFactory require('react-lite-misc').LoadingMore

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ a, div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'mentions-page'
  mixins: [mixinFinder, mixinQuery, mixinRouter, mixinSubscribe, PureRenderMixin]

  propTypes:
    className: T.string

  getDefaultProps: ->
    _teamId: T.string.isRequired
    router: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    isLoading: false
    resultsEnd: false
    showFileQueue: false
    mentionedMessages: @getMentionedMessages()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        mentionedMessages: @getMentionedMessages()

  makeQuery: ->
    assign {},
      { _teamId: @props._teamId },
      { _maxId: @state.mentionedMessages.last().get('_id') } if @state.mentionedMessages.size > 0

  sendSearchRequest: ->
    return if @state.resultsEnd or @state.isLoading

    @setState
      isLoading: true

    params = @makeQuery()
    mentionedMessageActions.read params
    , (resp) =>
      @setState
        isLoading: false
        resultsEnd: resp.length < mentionedMessageActions.MESSAGE_LIMIT
    , (error) =>
      @setState
        isLoading: false

  renderFileQueue: ->
    LiteModal
      name: 'file-queue'
      show: @state.showFileQueue
      onCloseClick: @onFileQueueHide
      FileQueueMentions
        _teamId: @getTeamId()
        query: @makeQuery()
        onClose: @onFileQueueHide
        messages: @state.mentionedMessages
        attachment: @state.cursorAttachment

  renderMessages: ->
    div className: 'container',
      div className: 'finder mentions-finder thin-scroll',
        LiteWheeling onScroll: @onScroll,
          @renderTimeline()

  renderTimeline: ->
    div className: 'timeline',
      if @state.mentionedMessages.size is 0
        unless @state.isLoading
          NoMentions()
      else
        @state.mentionedMessages
        .map (message) =>
          onClick = => @onMessageClick message
          onFileClick = (attachment) => @onFileClick attachment

          div key: message.get('_id'), className: 'wrap',
            MessageRich
              canEdit: false
              message: message
              onClick: onClick
              showTags: true
              onFileClick: onFileClick
              showActions: true
            @renderHint message
      LiteLoadingMore
        show: @state.isLoading or @state.resultsEnd and @state.mentionedMessages.size isnt 0
        end: @state.resultsEnd and @state.mentionedMessages.size isnt 0
        endLocale: lang.getText('no-more-search-results')

  render: ->
    div className: cx('finder-page mentions-page', @props.className),
      @renderMessages()
      @renderFileQueue()
