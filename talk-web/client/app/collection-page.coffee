cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
classnames = require 'classnames'

query = require '../query'
eventBus = require '../event-bus'

searchActions = require '../actions/search'
deviceActions = require '../actions/device'

routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

FilterTag = React.createFactory require './filter-tag'
MsgResult = React.createFactory require './msg-result'
StoryName = React.createFactory require './story-name'
TopicName = React.createFactory require './topic-name'
ContactName = React.createFactory require './contact-name'
FilterTopic = React.createFactory require './filter-topic'
MessageRich = React.createFactory require './message-rich'
SearchHeader = React.createFactory require './search-header'
FilterContact = React.createFactory require './filter-contact'
FilterType = React.createFactory require './filter-type'
FilterTimeRange = React.createFactory require './filter-time-range'
FileQueueCollection = React.createFactory require './file-queue-collection'
StoryResult = React.createFactory require './story-result'

LiteModal = React.createFactory require('react-lite-layered').Modal
LiteWheeling = React.createFactory require('react-lite-misc').Wheeling
LiteSearchBox = React.createFactory require('react-lite-misc').SearchBox
LiteLoadingMore = React.createFactory require('react-lite-misc').LoadingMore

NoResult = React.createFactory require '../module/no-result'
NoContent = React.createFactory require '../module/no-content'

ReactCSSTransitionGroup = React.createFactory require 'react-addons-css-transition-group'

hr = React.createFactory 'hr'
div = React.createFactory 'div'
span = React.createFactory 'span'

iconMap =
  file: 'icon-paperclip'
  post: 'icon-rich-text'
  link: 'icon-link'
  snippet: 'icon-pre'

# local types is not the same with types used on server
typeMap =
  'all-types': undefined
  'type-file': 'file'
  'type-rtf': 'rtf'
  'type-url': 'url'
  'type-snippet': 'snippet'

typeReversedMap =
  'file': 'type-file'
  'rtf':'type-rtf'
  'url':'type-url'
  'snippet':'type-snippet'

timeRangeReversedMap =
  'time-range-one-day': 'day'
  'time-range-one-week': 'week'
  'time-range-one-month': 'month'
  'time-range-quarter': 'quarter'

fileCategoryMap =
  'all-types': undefined
  images: 'image'
  documents: 'document'
  multimedia: 'media'
  others: 'other'

PureRenderMixin = require 'react-addons-pure-render-mixin'
T = React.PropTypes

module.exports = React.createClass
  displayName: 'collection-page'
  mixins: [PureRenderMixin]

  propTypes:
    router: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    # gets _roomId, _toId, query, type from url
    urlQuery = @props.router.get('query')
    # returns object
    _creatorId: urlQuery.get('_toId')
    _roomId: urlQuery.get('_roomId')
    _storyId: urlQuery.get('_storyId')
    isDirectMessage: if urlQuery.get('_toId') then true
    query: urlQuery.get('query') or ''
    isLoading: false
    results: Immutable.fromJS([])
    showFileQueue: false
    cursorAttachment: null
    page: 1
    resultsEnd: false
    type: typeReversedMap[urlQuery.get('type')] or 'all-types'
    timeRange: 'time-range-quarter'
    searchStory: false

  componentDidMount: ->
    @sendSearchRequest()

  # methods

  makeQuery: ->
    data =
      _creatorId: @state._creatorId
      _roomId: @state._roomId
      _storyId: @state._storyId
      _tagId: @state._tagId
      _teamId: @getTeamId()
      fileCategory: fileCategoryMap[@state.fileCategory]
      hasTag: @state.hasTag
      isDirectMessage: @state.isDirectMessage
      page: @state.page
      q: @state.query
      type: typeMap[@state.type]
      sort: {createdAt: {order: 'desc'}}
      timeRange: timeRangeReversedMap[@state.timeRange]

    if @state.isDirectMessage and @state._creatorId?
      _userId = query.userId(recorder.getState())
      data._creatorIds = data._toIds = [@state._creatorId, _userId]

    if @state.results.size
      # for api.messages.tags.get
      data._maxId = @state.results.last().get('_id')

    return data

  searchStories: (data) ->
    searchActions.story data,
      (resp) =>
        @setState
          isLoading: false
          results: @state.results.concat(Immutable.fromJS(resp.stories))
          page: (@state.page + 1)
          resultsEnd: resp.stories.length is 0
      , (error) =>
        @setState isLoading: false

  searchMessages: (data) ->
    searchActions.collection data,
      (resp) =>
        @setState
          isLoading: false
          results: @state.results.concat(resp.get('messages'))
          page: (@state.page + 1)
          resultsEnd: resp.get('messages').size is 0
      , (error) =>
        @setState isLoading: false

  sendSearchRequest: ->
    if @state.resultsEnd or @state.isLoading
      return
    @setState isLoading: true
    data = @makeQuery()
    if @state.searchStory
      @searchStories data
    else
      @searchMessages data

  getTeamId: ->
    @props.router.getIn(['data', '_teamId'])

  # events

  onCreatorChange: (_creatorId) ->
    newState =
      _creatorId: _creatorId
      page: 1, resultsEnd: false
      results: Immutable.fromJS([])
    @setState newState, @sendSearchRequest

  onChannelChange: (_roomId, isDirectMessage) ->
    newState =
      _roomId: _roomId
      _storyId: undefined
      isDirectMessage: isDirectMessage
      page: 1, resultsEnd: false
      results: Immutable.fromJS([])
    @setState newState, @sendSearchRequest

  onTagChange: (_tagId, filtered) ->
    newState =
      page: 1
      resultsEnd: false
      results: Immutable.fromJS([])
    if filtered
      newState.hasTag = true
      if _tagId?
        newState._tagId = _tagId
      else
        newState._tagId = undefined
    else
      newState._tagId = undefined
      newState.hasTag = false
    @setState newState, @sendSearchRequest

  onFileCategoryChange: (fileCategory) ->
    newState =
      fileCategory: fileCategory
      page: 1, resultsEnd: false
      results: Immutable.fromJS([])
    @setState newState, @sendSearchRequest

  onQueryChange: (urlQuery) ->
    @setState query: urlQuery

  onQueryConfirm: (urlQuery) ->
    newState =
      page: 1, resultsEnd: false
      results: Immutable.fromJS([])
    @setState newState, @sendSearchRequest

  onTypeChange: (type) ->
    newState =
      page: 1, resultsEnd: false
      results: Immutable.fromJS([])
      type: type
    @setState newState, @sendSearchRequest

  onTimeRangeChange: (timeRange) ->
    newState =
      page: 1, resultsEnd: false
      results: Immutable.fromJS([])
      timeRange: timeRange
    @setState newState, @sendSearchRequest

  onFileClick: (attachment) ->
    @setState showFileQueue: true, cursorAttachment: attachment
    deviceActions.viewAttachment attachment.get('_id')

  onFileQueueHide: ->
    @setState showFileQueue: false
    deviceActions.viewAttachment null

  onClose: ->
    routerHandlers.changeChannel @getTeamId(), @state._roomId, @state._creatorId

  onScroll: (eventInfo) ->
    if eventInfo.atBottom and eventInfo.goingDown
      @sendSearchRequest()

  onChange: ->
    newState =
      results: Immutable.List()
      page: 1
      query: query
      resultsEnd: false
    @setState newState, @sendSearchRequest

  onMessageClick: (message) ->
    _teamId = message.get('_teamId')
    _toId = message.get('_toId')
    _roomId = message.get('_roomId')
    _storyId = message.get('_storyId')
    _id = message.get('_id')
    _userId = query.userId(recorder.getState())
    if _storyId?
      # 好像story下暂时不支持搜索到message id
      routerHandlers.story _teamId, _storyId, {search: _id}
    else if _roomId?
      routerHandlers.room _teamId, _roomId, {search: _id}
    else # count on _toId
      if _toId is _userId
        _toId = message.get('_creatorId')
      routerHandlers.chat _teamId, _toId, {search: _id}

  onStoryClick: (story) ->
    _teamId = story.get('_teamId')
    _storyId = story.get('_id')
    routerHandlers.story _teamId, _storyId

  onSearch: (query) ->
    @setState
      query: query
      page: 1
      resultsEnd: false
      results: Immutable.List()
      searchStory: false
      @sendSearchRequest

  onSearchStory: (query) ->
    @setState
      query: query
      page: 1
      resultsEnd: false
      results: Immutable.List()
      searchStory: true
      @sendSearchRequest

  renderFilterContact: ->
    FilterContact
      _teamId: @getTeamId()
      _creatorId: @state._creatorId
      onChange: @onCreatorChange

  renderFilterTag: ->
    unless @state.searchStory
      FilterTag
        _teamId: @getTeamId()
        onChange: @onTagChange
        _tagId: @state._tagId
        hasTag: @state.hasTag

  renderFilterTopic: ->
    FilterTopic
      _teamId: @getTeamId()
      _roomId: @state._roomId
      onChange: @onChannelChange
      isDirectMessage: @state.isDirectMessage

  renderFileType: ->
    unless @state.searchStory
      FilterType
        type: @state.type
        onChange: @onTypeChange

  renderFilterTimeRange: ->
    FilterTimeRange
      type: @state.timeRange
      onChange: @onTimeRangeChange

  getFileResults: ->
    @state.results.map (message) ->
      message.get('attachments')
      .filter (attachment) ->
        attachment.get('category') is 'file'
      .map (attachment) ->
        Immutable.Map {message, attachment}
    .filterNot (arr) ->
      arr.size is 0
    .flatten(true)

  renderResults: ->
    if @state.type is 'file'
      @getFileResults().map (message) =>
        MsgResult
          key: message.getIn(['attachment', '_id']), type: @state.type, _teamId: @getTeamId()
          message: message.get('message'), attachment: message.get('attachment'), onFileClick: @onFileClick
    else
      @state.results.map (message) =>
        MsgResult
          key: message.getIn(['attachment', '_id']), type: @state.type, _teamId: @getTeamId()
          message: message, attachment: message.getIn(['attachments', 0])

  renderFileQueue: ->
    LiteModal
      name: 'file-queue'
      show: @state.showFileQueue
      onCloseClick: @onFileQueueHide
      FileQueueCollection
        onClose: @onFileQueueHide
        messages: @state.results
        attachment: @state.cursorAttachment
        _teamId: @getTeamId()
        _toId: @state._creatorId
        _roomId: @state._roomId
        query: @makeQuery()

  renderFinderResults: ->
    iconClass = cx 'icon', iconMap[@state.type]

    div className: 'finder',
      div className: 'table',
        div className: 'header msg-result',
          div className: 'content',
            span className: iconClass
          div className: 'creator',
            span className: 'icon icon-user'
          div className: 'channel',
            span className: 'icon icon-sharp'
          div className: 'time',
            span className: 'icon icon-calendar'
        hr className: 'divider'
        div className: 'body',
          if @state.results.size is 0
            unless @state.isLoading
              NoResult()
          else
            @renderResults()
          LiteLoadingMore
            show: @state.isLoading or @state.resultsEnd and @state.results.size isnt 0
            end: @state.resultsEnd and @state.results.size isnt 0
            endLocale: lang.getText('no-more-search-results')

  renderTopicHint: (message) ->
    div className: 'group',
      TopicName topic: message.get('room')

  renderContactHint: (message) ->
    toContact = query.contactsByOne(recorder.getState(), @getTeamId(), message.get('_toId'))
    div className: 'group',
      ContactName contact: toContact, _teamId: @getTeamId()

  renderStoryHint: (message) ->
    story = message.get 'story'
    category = story.get 'category'
    title = story.getIn ['data', 'title']
    if category is 'file'
      title = story.getIn ['data', 'fileName']

    div className: 'group',
      StoryName
        title: title
        category: category

  renderTimeline: ->
    div className: 'timeline',
      if @state.results.size is 0
        unless @state.isLoading
          NoResult()
      else if @state.searchStory
        @renderStories()
      else
        @renderMessages()
      LiteLoadingMore
        show: @state.isLoading or @state.resultsEnd and @state.results.size isnt 0
        end: @state.resultsEnd and @state.results.size isnt 0
        endLocale: lang.getText('no-more-search-results')

  renderStories: ->
    @state.results.map (story) =>
      onClick = => @onStoryClick story
      div className: 'wrap',
        StoryResult
          key: story.get('_id')
          story: story
          onClick: onClick

  renderMessages: ->
    @state.results.map (message) =>
      onClick = => @onMessageClick message
      div className: 'wrap', key: message.get('_id'), onClick: onClick,
        MessageRich message: message, onFileClick: @onFileClick
        if message.get('room')
          @renderTopicHint message
        else if message.get('_toId')
          @renderContactHint message
        else if message.get('_storyId')
          @renderStoryHint message

  renderControls: ->
    div className: 'controls',
      @renderFilterContact()
      @renderFilterTopic()
      @renderFilterTag()
      @renderFileType()
      @renderFilterTimeRange()

  renderHeader: ->
    div className: 'header',
      SearchHeader
        _teamId: @getTeamId()
        onSearch: @onSearch
        onSearchStory: @onSearchStory

  renderFinder: ->
    div className: 'container',
      div className: 'finder collection-finder',
        LiteWheeling delay: 0, onScroll: @onScroll,
          div className: 'panel',
            @renderControls()
          if @state.type in ['file', 'link', 'post', 'snippet']
            @renderFinderResults()
          else
            @renderTimeline()
          @renderFileQueue()

  render: ->
    div className: 'finder-page collection-page flex-space',
      @renderHeader()
      @renderFinder()
