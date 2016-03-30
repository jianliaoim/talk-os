cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'
eventBus = require '../event-bus'

routerHandlers = require '../handlers/router'

draftActions = require '../actions/draft'
searchActions = require '../actions/search'
favoriteActions = require '../actions/favorite'

FavoritesHeader = React.createFactory require './favorites-header'

lang = require '../locales/lang'

mixinFinder = require '../mixin/finder-mixin'
mixinSubscribe = require '../mixin/subscribe'

MessageRich = React.createFactory require './message-rich'
FavoriteDeleter = React.createFactory require './favorite-deleter'
FileQueueFavorite = React.createFactory require './file-queue-favorite'

NoFavorite = React.createFactory require '../module/no-favorite'

LightModal = React.createFactory require '../module/light-modal'
LiteWheeling = React.createFactory require('react-lite-misc').Wheeling
LiteLoadingMore = React.createFactory require('react-lite-misc').LoadingMore

{ a, div, span } = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'favorites-page'
  mixins: [ mixinSubscribe, mixinFinder ]

  propTypes:
    _teamId: T.string.isRequired
    router: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    urlQuery = @props.router.get('query')

    query: ''
    results: Immutable.List()
    isLoading: false
    showFileQueue: false
    cursorAttachment: null
    resultsEnd: false
    page: 2 # page 1 的请求在data-rely中发出
    _roomId: urlQuery.get('_roomId')

  componentDidMount: ->
    @subscribe recorder, =>
      @setState results: @getResults()

  getResults: ->
    query.favResults(recorder.getState())

  getRoomId: ->
    @props.router.getIn(['query', '_roomId'])

  getToId: ->
    @props.router.getIn(['query', '_toId'])

  clearResults: ->
    favoriteActions.clearResults()

  sendSearchRequest: ->
    if @state.resultsEnd or @state.isLoading
      return
    @setState isLoading: true
    data = @makeQuery()
    favoriteActions.searchFavorite data,
      (resp) =>
        @setState
          isLoading: false
          page: (@state.page + 1)
          resultsEnd: resp.get('favorites').size is 0
      , (error) =>
        @setState isLoading: false

  makeQuery: ->
    data =
      _teamId: @props._teamId
      page: @state.page
    # API does not accept empty string as the query
    if @state._creatorId
      data._creatorId = @state._creatorId
    else if @state._roomId
      data._roomId = @state._roomId
    if @state.query
      data.q = @state.query
    unless data.q
      data.sort = {favoritedAt: {order: 'desc'}}

    return data

  onClose: ->
    routerHandlers.changeChannel @props._teamId, @getRoomId(), @getToId()

  onHeaderQueryChange: (query) ->
    @clearResults()
    newState =
      page: 1
      query: query
      resultsEnd: false
    @setState newState, @sendSearchRequest

  renderFileQueue: ->
    LightModal
      name: 'file-queue'
      show: @state.showFileQueue
      onCloseClick: @onFileQueueHide
      FileQueueFavorite
        onClose: @onFileQueueHide
        messages: @state.results
        attachment: @state.cursorAttachment
        query: @makeQuery()
        _teamId: @props._teamId
        _roomId: @props._roomId
        isFavorite: true

  renderToolbar: (_messageId) ->
    div className:'toolbar',
      FavoriteDeleter
        _messageId: _messageId

  renderNoResult: ->
    NoFavorite()

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
              isFavorite: true
              canEdit: false
            @renderHint message
            @renderToolbar message.get('_id')
      LiteLoadingMore
        show: @state.isLoading or @state.resultsEnd and @state.results.size isnt 0
        end: @state.resultsEnd and @state.results.size isnt 0
        endLocale: lang.getText('no-more-search-results')

  renderFinder: ->
    div className: 'container',
      div className: 'finder favorites-finder',
        LiteWheeling onScroll: @onScroll,
          @renderTimeline()
        @renderFileQueue()

  renderHeader: ->
    div className: 'header',
      FavoritesHeader
        _teamId: @props._teamId
        onChange: @onHeaderQueryChange

  render: ->
    div className: 'finder-page favorites-page flex-space',
      @renderHeader()
      @renderFinder()
