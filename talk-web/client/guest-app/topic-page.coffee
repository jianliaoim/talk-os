React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'
time = require '../util/time'
find = require '../util/find'
schema = require '../schema'
notify = require '../util/notify'
eventBus = require '../event-bus'

messageActions = require '../actions/message'
mixinSubscribe = require '../mixin/subscribe'

lang = require '../locales/lang'

# components
TopicHeader = React.createFactory require './topic-header'
TopicBanner = React.createFactory require './topic-banner'

MessageArea     = React.createFactory require '../app/message-area'
MessageEditor   = React.createFactory require '../app/message-editor'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'topic-page'
  mixins: [mixinSubscribe]

  propTypes:
    _teamId: T.string.isRequired
    _roomId: T.string.isRequired
    router: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    isLoading: false
    editorHeight: 170
    messageEnd: false
    topic: @getTopic()
    members: @getMembers()
    messages: @getMessages()
    notifyBanner: @getNotifyBanner()
    draftMessage: schema.fakeEmptyMessage.set 'body', @getMessageDraft()
    isTuned: @getTuned()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        topic: @getTopic()
        isTuned: @getTuned()
        members: @getMembers()
        messages: @getMessages()
        notifyBanner: @getNotifyBanner()
        draftMessage: @state.draftMessage.set 'body', @getMessageDraft()

    eventBus.emit 'dirty-action/new-message'

  getTopic: ->
    query.topicsByOne(recorder.getState(), @props._teamId, @props._roomId)

  getMembers: ->
    query.membersBy(recorder.getState(), @props._teamId, @props._roomId) or Immutable.List()

  getMessages: ->
    query.messagesBy(recorder.getState(), @props._teamId, @props._roomId) or Immutable.List()

  getNotifyBanner: ->
    query.bannerNotices(recorder.getState())

  getMessageDraft: ->
    query.draftsDraftBy(recorder.getState(), @props._teamId, @props._roomId) or ''

  # event handlers

  onClearUnread: ->
    unread = @state.topic.get('unread') or 0
    if unread is 0 then return # no unread to clear
    data =
      _teamId: @props._teamId
      _roomId: @props._roomId
      _latestReadMessageId: find.maxId @state.messages
    messageActions.messageClear data

  isNewInGeneral: ->
    prefs = query.prefs(recorder.getState())
    @state.topic.get('isGeneral') and (not prefs.get('hasShownTips'))

  fetchHistory: ->
    return if @state.messageEnd
    return if @state.isLoading
    if @isNewInGeneral()
      @setState messageEnd: true
      return
    @setState isLoading: true
    data =
      _teamId: @props._teamId
      _roomId: @state.topic.get('_id')
      _maxId: find.minId @state.messages
    messageActions.messageMore data,
      (resp) =>
        if resp.length < 10
        then @setState isLoading: false, messageEnd: true
        else @setState isLoading: false
      (resp) ->
        console.error 'load history', resp

  onMessageSubmit: (content, displayType) ->
    _userId = query.userId(recorder.getState())
    params =
      _teamId: @props._teamId
      _roomId: @state.topic.get('_id')
      _creatorId: _userId
      body: content
      displayType: displayType

    messageActions.messageCreate params, (resp) ->
      eventBus.emit 'dirty-action/new-message'

  onScrollReachTop: ->
    @fetchHistory()

  onScrollReachBottom: ->
    @onClearUnread()

  onScrollStayBottom: ->
    @onClearUnread()

  getTuned: ->
    query.isTuned recorder.getState()

  renderTitle: ->
    if @state.topic?.get('topic')?
      document.title = @state.topic.get('topic')
      notify.favicon @state.topic.get('unread')

  renderHeader: ->
    TopicHeader
      _teamId: @props._teamId
      _roomId: @props._roomId
      topic: @state.topic or Immutable.Map()
      members: @state.members
      router: @props.router

  renderBanner: ->
    TopicBanner showEmailHint: false

  renderMessageArea: ->
    MessageArea
      loading: @state.isLoading
      isLoadingAfter: false
      end: @state.messageEnd
      onScrollReachTop: @onScrollReachTop
      onScrollReachBottom: @onScrollReachBottom
      onScrollStayBottom: @onScrollStayBottom
      onUnreadClick: @onScrollReachBottom
      editorHeight: @state.editorHeight
      unread: @state.topic?.get('unread') or 0
      isTuned: @state.isTuned
      banner: if @state.messageEnd then @renderBanner()
      routerQuery: @props.router.get('query')
      isMessageHighlight: false
      messages: @state.messages or Immutable.List()
      readMessageId: @state.topic?.get('_latestReadMessageId') or 'nothing'
      notifyBanner: @state.notifyBanner
      router: @props.router
      _teamId: @props._teamId
      _roomId: @props._roomId

  renderEditor: ->
    MessageEditor
      showButton: false
      showActions: true
      _teamId: @props._teamId
      _roomId: @props._roomId
      _toId: null
      _storyId: null
      _channelId: null
      _channelType: null
      onSubmit: @onMessageSubmit
      message: @state.draftMessage

  render: ->
    @renderTitle()

    div className: 'topic-page', lang: lang.getText('dnd-guide'),
      @renderHeader()
      @renderMessageArea()
      @renderEditor()
