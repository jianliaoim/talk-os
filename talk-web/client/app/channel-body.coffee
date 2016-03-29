
React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
uploadUtil  = require '../util/upload'

if typeof window isnt 'undefined'
  FileAPI = require 'fileapi'

query = require '../query'
config = require '../config'
eventBus = require '../event-bus'

prefsActions = require '../actions/prefs'
messageActions = require '../actions/message'
searchMessageActions = require '../actions/search-message'

handlers = require '../handlers'
unreadHandlers = require '../handlers/unread'

mixinSubscribe = require '../mixin/subscribe'

lang = require '../locales/lang'

find = require '../util/find'
time = require '../util/time'
detect = require '../util/detect'
orders = require '../util/orders'
assemble = require '../util/assemble'

TopicJoin = React.createFactory require './topic-join'
TopicBanner = React.createFactory require './topic-banner'
MessageArea = React.createFactory require './message-area'
NotifyBanner = React.createFactory require './notify-banner'
ChannelBanner = React.createFactory require './channel-banner'
ContactBanner = React.createFactory require './contact-banner'
MessageEditor = React.createFactory require './message-editor'

LiteLoadingIndicator = React.createFactory require('react-lite-misc').LoadingIndicator

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ p, div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'channel-body'
  mixins: [ PureRenderMixin, mixinSubscribe]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    _channelId: T.string
    _channelType: T.string.isRequired
    draft: T.string
    routerQuery: T.instanceOf(Immutable.Map).isRequired
    channel: T.instanceOf(Immutable.Map).isRequired
    contacts: T.instanceOf(Immutable.List)
    messages: T.instanceOf(Immutable.List).isRequired
    notification: T.instanceOf(Immutable.Map).isRequired
    notifyBanner: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    isEnd: @props.messages.size < 10
    isHover: false
    isJoined: @getSearchMessages(@props.messages).isJoined
    isSearch: @props.routerQuery.has('search')
    isLoading: false
    isLoadingAfter: false
    searchMessages: @getSearchMessages(@props.messages).searchMessages
    isMessageHighlight: false
    isTuned: @getTuned()
    isClearingUnread: @getIsClearingUnread()

  componentDidMount: ->
    dropTarget = @refs.root
    FileAPI.event.dnd dropTarget, @onIsHover, @onFilesLoad
    @subscribe recorder, =>
      @setState
        isJoined: @getSearchMessages(@props.messages).isJoined
        searchMessages: @getSearchMessages(@props.messages).searchMessages
        isTuned: @getTuned()
        isClearingUnread: @getIsClearingUnread()

    if @state.isSearch
      @highlightSelectedMessage()
    else
      eventBus.emit 'dirty-action/new-message'

  getIsClearingUnread: ->
    query.isClearingUnread recorder.getState(), @props._teamId, @props._channelId

  getTuned: ->
    query.isTuned recorder.getState()

  drawDraft: ->
    Immutable.fromJS body: @props.draft

  getCreator: ->
    if @props._channelType is 'room'
      @props.contacts.find((contact) => contact.get('_id') is @props.channel.get('_creatorId')) or Immutable.Map()
    else Immutable.Map()

  getChannel: ->
    switch @props._channelType
      when 'chat'
        _toId: @props._channelId
      when 'room'
        _roomId: @props._channelId
      when 'story'
        _storyId: @props._channelId

  getMessages: ->
    if @state.isSearch
      if @state.isJoined
        latestMessages = @props.messages
        latestMessageIds = latestMessages.map((item) -> item.get('_id'))
        inCollection = (item) -> latestMessageIds.contains(item.get('_id'))
        searchMessages = @state.searchMessages.filterNot(inCollection)
        searchMessages.concat(latestMessages).sort(orders.imMsgByDate)
      else
        @state.searchMessages.sort(orders.imMsgByDate)
    else
      messages = @props.messages or Immutable.List()
      messages.sort(orders.imMsgByDate)

  getUnread: ->
    @props.notification.get('unreadNum') or 0

  getSearchMessages: (messages) ->
    searchMessages = query.searchMessages recorder.getState()
    historyIds = searchMessages.map((item) -> item.get('_id'))
    latestIds = messages.map((item) -> item.get('_id'))
    isJoined = historyIds.some (_messageId) -> latestIds.contains _messageId

    searchMessages: searchMessages
    isJoined: isJoined

  isQuit: ->
    return false if @props._channelType is 'story'
    not detect.inChannel(@props.channel)

  isArchived: ->
    @props.channel.get('isArchived')

  isPreview: ->
    @isQuit() or @isArchived()

  clearUnread: ->
    if @getUnread() > 0 and not @state.isClearingUnread
      unreadHandlers.clear @props.notification

  detectNotExistMember: (messageBody, resp) ->
    detect.mentionInContent messageBody
    .forEach (targetId) =>
      memberIds = @props.channel.get '_memberIds'
      contactIds = @props.contacts.map (x) -> x.get '_id'

      isMember = memberIds.includes targetId
      isContact = contactIds.includes targetId
      if not isMember and isContact
        target = @props.contacts.find (x) -> x.get('_id') is targetId
        data =
          _roomId: if @props._channelType is 'room' then @props._channelId else null
          _teamId: @props._teamId
          _storyId: if @props._channelType is 'story' then @props._channelId else null
          alias: query.contactPrefsBy(recorder.getState(), @props._teamId, target.get('_id'))?.get('alias')
          sender: query.user(recorder.getState())
          talkai: @props.contacts.find (x) -> x.get('service') is 'talkai'
          receiver: target

        nextMoment = time.nextMoment resp.createdAt
        localMessage = assemble.localMessage data
        localMessage.createdAt = localMessage.updatedAt = nextMoment

        messageActions.createLocal localMessage
        eventBus.emit 'dirty-action/new-message'

  fetchHistory: (cb) ->
    return if @state.isEnd
    return if @state.isLoading
    @setState
      isLoading: true

    data = assign {}, @getChannel(),
      _teamId: @props._teamId
    _maxId = find.minId @props.messages
    if _maxId?
      data._maxId = _maxId
    messageActions.messageMore data, (resp) =>
      newState =
        isLoading: false
        isEnd: false
      if resp.length < 10
        newState.isEnd = true
      @setState newState, -> cb?()

  fetchSearchBefore: (cb) ->
    return if @state.isLoading or @state.isEnd
    data = assign {}, @getChannel(),
      _maxId: find.minId @getMessages()
      _teamId: @props._teamId

    @setState isLoading: true
    searchMessageActions.before data, (resp) =>
      newState = isLoading: false
      if resp.length < 10
        newState.isEnd = true
      @setState newState, -> cb?()

  fetchSearchAfter: ->
    return if @state.isLoadingAfter
    data = assign {}, @getChannel(),
      _teamId: @props._teamId
      _minId: find.maxId @getMessages()
    @setState isLoadingAfter: true
    searchMessageActions.after data, (resp) =>
      newState = isLoadingAfter: false
      if resp.length < 10
        newState.isJoined = true
      @setState newState

  firstTalkWithAi: ->
    customOptions = query.prefs(recorder.getState()).get('customOptions')
    if detect.isTalkai(@props.channel) and
    customOptions.needTalkAIReply and
    (not customOptions.hasGetReply)
      customOptions = assign {}, customOptions,
        hasGetReply: true
      prefsActions.prefsUpdate customOptions: customOptions
      # Mock local message
      data =
        _roomId: if @props._channelType is 'room' then @props._channelId else null
        _teamId: @props._teamId
        _storyId: if @props._channelType is 'story' then @props._channelId else null
        body: lang.getText 'robot-first-res'
        talkai: @props.channel
      localMessage = assemble.localTalkMessage data
      messageActions.createLocal localMessage
      eventBus.emit 'dirty-action/new-message'

  highlightSelectedMessage: ->
    rootEl = @refs.root
    selectedEl = rootEl.querySelector('.message-rich.is-selected')
    selectedEl or= rootEl.querySelector('.message-slim.is-selected')
    if selectedEl
      selectedEl.scrollIntoView()
      @setState isMessageHighlight: true
      setTimeout =>
        if @isMounted()
          @setState isMessageHighlight: false
      , 5000

  onScrollReachTop: (cb) ->
    if @state.isSearch
      @fetchSearchBefore(cb)
    else
      @fetchHistory(cb)

  onScrollReachBottom: ->
    if @state.isSearch and (not @state.isJoined)
      @fetchSearchAfter()
    else
      @clearUnread()

  onSubmit: (content, displayType) ->
    data = assign {}, @getChannel(),
      _teamId: @props._teamId
      _creatorId: @props._userId
      body: content
      displayType: displayType

    messageActions.messageCreate data, (resp) =>
      eventBus.emit 'dirty-action/new-message'
      if @props._channelType isnt 'chat'
        @detectNotExistMember data.body, resp
      @firstTalkWithAi()

    @setState isSearch: false

  onUnreadClick: ->
    if @state.isSearch
      @setState isSearch: false
    @clearUnread()

  onIsHover: (isHover) ->
    if @state.isHover isnt isHover
      @setState isHover: isHover

  onFilesLoad: (files) ->
    uploadUtil.uploadFiles files,
      multiple: true
      onCreate: handlers.fileCreate
      onProgress: handlers.fileProgress
      onSuccess: handlers.fileSuccess
      onError: handlers.fileError
      metaData: handlers.file.getNewMessageInfo()

  # renderers

  renderNotifyBanner: ->
    NotifyBanner data: @props.notifyBanner

  renderBanner: ->
    switch @props._channelType
      when 'chat'
        ContactBanner
          _teamId: @props._teamId
          data: @props.channel
      when 'room'
        TopicBanner
          topic: @props.channel
          creator: @getCreator()
          preview: @isPreview()
      when 'story'
        ChannelBanner
          channel: @props.channel

  renderEditor: ->
    MessageEditor
      _toId: if @props._channelType is 'chat' then @props._channelId
      _roomId: if @props._channelType is 'room' then @props._channelId
      _teamId: @props._teamId
      _storyId: if @props._channelType is 'story' then @props._channelId
      _channelId: @props._channelId
      _channelType: @props._channelType
      message: @drawDraft()
      onSubmit: @onSubmit
      showButton: false
      showActions: true

  renderMessage: ->
    MessageArea
      _toId: if @props._channelType is 'chat' then @props._channelId
      _roomId: if @props._channelType is 'room' then @props._channelId
      _teamId: @props._teamId
      _storyId: if @props._channelType is 'story' then @props._channelId
      _channelId: @props._channelId
      _channelType: @props._channelType
      end: @state.isEnd
      banner: if @state.isEnd then @renderBanner()
      routerQuery: @props.routerQuery
      unread: @getUnread()
      isTuned: @state.isTuned
      loading: @state.isLoading
      preview: @isPreview()
      isSearch: @state.isSearch
      messages: @getMessages()
      onUnreadClick: @onUnreadClick
      readMessageId: @props.notification.get('_latestReadMessageId')
      isLoadingAfter: @state.isLoadingAfter
      isClearingUnread: @state.isClearingUnread
      onScrollReachTop: @onScrollReachTop
      isMessageHighlight: @state.isMessageHighlight
      onScrollReachBottom: @onScrollReachBottom

  renderJoin: ->
    TopicJoin
      topic: @props.channel

  renderQuitTip: ->
    div className: 'quit-wrapper',
      div className: 'quit-mask',
        p className: 'text muted', lang.getText('this-member-left')

  renderPreviewHint: ->
    if @isQuit()
      if @props._channelType is 'chat'
        @renderQuitTip()
      else
        @renderJoin()
    else # archived and everything else
      null

  render: ->
    div ref: 'root', className: 'channel-body flex-space flex-vert',
      @renderNotifyBanner()
      @renderMessage()
      if @isPreview()
        @renderPreviewHint()
      else
        @renderEditor()
      if @state.isHover
        div className: 'uploader-cover'
