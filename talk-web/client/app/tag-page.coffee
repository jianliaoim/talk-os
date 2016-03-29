
React = require 'react'
Immutable = require 'immutable'
cx = require 'classnames'
recorder = require 'actions-recorder'

query = require '../query'
eventBus = require '../event-bus'
mixinSubscribe = require '../mixin/subscribe'

routerHandlers = require '../handlers/router'

lang        = require '../locales/lang'

tagActions   = require '../actions/tag'
mixinFinder       = require '../mixin/finder-mixin'

div              = React.createFactory 'div'
span             = React.createFactory 'span'
a                = React.createFactory 'a'
TagShelf         = React.createFactory require './tag-shelf'
FilterContact    = React.createFactory require './filter-contact'
FilterTopic      = React.createFactory require './filter-topic'
SearchBox        = React.createFactory require('react-lite-misc').SearchBox
NoResult         = React.createFactory require '../module/no-result'
LoadingMore      = React.createFactory require('react-lite-misc').LoadingMore
MessageRich      = React.createFactory require './message-rich'
BodyModal        = React.createFactory require 'react-lite-layered/lib/modal'
Wheeling         = React.createFactory require('react-lite-misc').Wheeling
FileQueueTag     = React.createFactory require './file-queue-tag'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'tag-page'
  mixins: [ mixinSubscribe, mixinFinder ]

  propTypes:
    _teamId: T.string.isRequired
    router: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    urlQuery = @props.router.get('query')

    _roomId: urlQuery.get('_roomId')
    _storyId: urlQuery.get('_storyId')
    isDirectMessage: if urlQuery.get('_toId') then true
    results: Immutable.List()
    isLoading: false
    showFileQueue: false
    cursorAttachment: null
    resultsEnd: false
    hasTag: true
    page: 2 # page 1 的请求在data-rely中发出
    showTags: true
    _tagId: urlQuery.get('_tagId')
    showTagAction: true
    user: query.user(recorder.getState())
    tags: @getTags()

  getRoomId: ->
    @props.router.getIn(['query', '_roomId'])

  getToId: ->
    @props.router.getIn(['query', '_toId'])

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        tags: @getTags()
        results: @getResults()

  getTags: ->
    query.tagsBy(recorder.getState(), @props._teamId) or Immutable.List()

  getResults: ->
    query.taggedResults(recorder.getState())

  clearResults: ->
    tagActions.clearResults()

  sendSearchRequest: ->
    if @state.resultsEnd or @state.isLoading
      return
    @setState isLoading: true
    data = @makeQuery()
    tagActions.searchTagged data,
      (resp) =>
        @setState
          isLoading: false
          page: (@state.page + 1)
          resultsEnd: resp.get('messages').size is 0
      , (error) =>
        @setState isLoading: false

  makeQuery: ->
    data =
      _teamId: @props._teamId
      hasTag: @state.hasTag
      _creatorId: @state._creatorId
      _roomId: @state._roomId
      _tagId: @state._tagId
      isDirectMessage: @state.isDirectMessage
      page: @state.page
      sort: {updatedAt: {order: 'desc'}}
    if @state.query
      data.q = @state.query
    if @state.results.size
      # for api.messages.tags.get
      data._maxId = @state.results.last().get('_id')

    return data

  onTagClick: (id) ->
    newState =
      page: 1
      _tagId: id
      resultsEnd: false
    @clearResults()
    @setState newState, @sendSearchRequest

  onAllTagsSelect: ->
    newState =
      page: 1
      _tagId: undefined
      resultsEnd: false
    @clearResults()
    @setState newState, @sendSearchRequest

  onClose: ->
    routerHandlers.changeChannel @props._teamId, @getRoomId(), @getToId()

  renderToolbar: ->
    #no action yet

  renderFileQueue: ->
    BodyModal
      name: 'file-queue'
      show: @state.showFileQueue
      onCloseClick: @onFileQueueHide
      FileQueueTag
        onClose: @onFileQueueHide
        messages: @state.results
        attachment: @state.cursorAttachment
        query: @makeQuery()
        _teamId: @props._teamId
        _roomId: @state._roomId

  renderNoResult: ->
    NoResult()

  renderTags: ->
    TagShelf
      tags: @state.tags
      _tagId: @state._tagId
      _userId: @state.user.get('_id')
      _teamId: @props._teamId
      selectAll: not @state._tagId? and @state.hasTag
      onTagClick: @onTagClick
      onAllTagsSelect: @onAllTagsSelect

  renderTimeline: ->
    div className: 'timeline',
      if @state.results.size is 0
        unless @state.isLoading
          @renderNoResult()
      else
        @state.results.map (message) =>
          onClick = => @onMessageClick message
          div className: 'wrap', key: message.get('_id'),
            MessageRich
              message: message
              onClick: onClick
              onFileClick: @onFileClick
              showTags: @state.showTags
              showActions: @state.showTagAction
            @renderHint message
            @renderToolbar message.get('_id')
      LoadingMore
        show: @state.isLoading or @state.resultsEnd and @state.results.size isnt 0
        end: @state.resultsEnd and @state.results.size isnt 0
        endLocale: lang.getText('no-more-search-results')

  renderFinder: ->
    div className: 'container',
      div className: 'finder tag-finder',
        div className: 'panel',
          div className: 'controls rich-line',
            @renderFilterContact()
            @renderFilterTopic()
            @renderSearchbox()
        Wheeling onScroll: @onScroll,
          @renderTimeline()
          @renderFileQueue()
      div className: 'side',
        @renderTags()

  render: ->
    div className: 'finder-page tag-page flex-space',
      @renderFinder()
