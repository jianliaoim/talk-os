Q = require 'q'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

api = require '../network/api'
lang = require '../locales/lang'
config = require '../config'
inteActions = require '../actions/inte'
mixinInteEvents = require '../mixin/inte-events'
mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'

LightDropdown = React.createFactory require '../module/light-dropdown'

{ a, div, span } = React.DOM
editableFields = Immutable.List ['config', '_roomId', '_teamId', 'title', 'description', 'iconUrl']

module.exports = React.createClass
  displayName: 'inte-trello'
  mixins: [mixinCreateTopic, mixinInteEvents, mixinInteHandler, PureRenderMixin]

  getInitialState: ->
    showBoards: false
    trelloBoards: Immutable.List()
    trelloAccount: null
    hasTrelloAccount: false
    loadingTrelloBoards: true
    loadTrelloBoardsError: false
    checkedTrelloBoardModelId: null

  componentDidMount: ->
    @onLoadTrelloBoards()

  hasChanges: ->
    editableFields
      .map (v) =>
        if v is '_teamId'
          @props.inte.get('_teamId') is @props._teamId
        else if v is 'config'
          if @state.checkedTrelloBoardModelId?
            @props.inte.getIn(['config', 'modelId']) is @state.checkedTrelloBoardModelId
          else
            true
        else
          prev = @props.inte.get v
          next = @state[v]
          (not next) or (prev is next)
      .some (v) -> not v

  isToSubmit: ->
    return false if @state.isSending
    return false if @state.loadingTrelloBoards
    return false if @state.loadTrelloBoardsError
    return false if not @state.trelloAccount?
    return false if not @state._roomId?
    return false if not @state.checkedTrelloBoardModelId
    return true

  onBoardsSelectorToggle: ->
    @setState
      showBoards: not @state.showBoards

  onCreate: ->
    checkedTrelloBoardModelId = @state.checkedTrelloBoardModelId
    trelloBoard = @state.trelloBoards.find (v) -> v.get('modelId') is checkedTrelloBoardModelId

    data =
      _roomId: @state._roomId
      _teamId: @props._teamId
      category: 'trello'
      config:
        modelId: trelloBoard.get 'modelId'
        modelName: trelloBoard.get 'modelName'
      description: @state.description
      iconUrl: @state.iconUrl
      title: @state.title

    @setState isSending: true
    inteActions.inteCreate data,
      (resp) =>
        @setState
          isSending: false
        @onPageBack true
      (error) =>
        @setState
          isSending: false

  onUpdate: ->
    if checkedTrelloBoardModelId
      checkedTrelloBoardModelId = @state.checkedTrelloBoardModelId
      trelloBoard = @state.trelloBoards.find (v) -> v.get('modelId') is checkedTrelloBoardModelId

    data =
      _roomId: @state._roomId
      _teamId: @props._teamId
      config: trelloBoard?.toJS() or @props.inte.get('config').toJS()
      description: @state.description
      iconUrl: @state.iconUrl
      title: @state.title

    @setState isSending: true
    inteActions.inteUpdate @props.inte.get('_id'), data,
      (resp) =>
        @setState
          isSending: false
        @onPageBack true
      (error) =>
        @setState
          isSending: false

  onCheckTrelloBoard: (trelloBoard) ->
    @setState
      checkedTrelloBoardModelId: trelloBoard.get('modelId')

  onLoadTrelloBoards: ->
    @_getTrelloAccount()
      .then =>
        @setState
          loadingTrelloBoards: true
        @_getTrelloBoards()
      .then (res) =>
        boards = Immutable.fromJS res
        checkedTrelloBoardModelId = @props.inte?.getIn ['config', 'modelId']
        @setState
          trelloBoards: boards
          loadingTrelloBoards: false
          checkedTrelloBoardModelId: checkedTrelloBoardModelId or null
      .catch =>
        @setState
          loadingTrelloBoards: false
          loadTrelloBoardsError: true
      .done()

  onTrelloBind: ->
    window.location = "#{config.accountUrl}/union/trello?method=bind&next_url=#{encodeURIComponent window.location}"

  renderAccount: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('connect-to-trello')
      if @state.hasTrelloAccount
        div className: 'value showname-table as-line',
          span className: 'showname', @state.trelloAccount.get 'name'
          a className: 'is-trigger', onClick: @onTrelloBind, lang.getText('changeBinding')
      else
        div className: 'value showname-table as-line',
          span className: 'text is-minor', lang.getText('noBinding')
          a className: 'is-trigger', onClick: @onTrelloBind, lang.getText('addBinding')

  renderBoard: ->
    @state.trelloBoards.map (trelloBoard) =>
      onClick = => @onCheckTrelloBoard trelloBoard
      div className: 'item', key: trelloBoard.get('modelId'), onClick: onClick,
        trelloBoard.get('modelName')

  renderBoards: ->
    checkedTrelloBoardModelId = @state.checkedTrelloBoardModelId
    selectedBoard = @state.trelloBoards.find (v) -> v.get('modelId') is checkedTrelloBoardModelId

    LightDropdown
      name: 'inte-trello'
      show: @state.showBoards
      onToggle: @onBoardsSelectorToggle
      defaultText: lang.getText('select-project')
      displayText: selectedBoard?.get('modelName') or undefined
      @renderBoard()

  renderBoardsSelector: ->
    return if not @state.hasTrelloAccount

    if @state.loadingTrelloBoards
      div className: 'table-pair',
        div className: 'attr',
          div className: 'title', lang.getText('project-name')
          div className: 'about muted', lang.getText('on-select-project')
        div className: 'value',
          span className: 'text is-minor', lang.getText('loading')
    else if @state.loadTrelloBoardsError
      div className: 'table-pair',
        div className: 'attr',
          div className: 'title', lang.getText('project-name')
          div className: 'about muted', lang.getText('on-select-project')
        div className: 'value row',
          span className: 'text is-minor', lang.getText('loading-failure')
          a className: 'is-trigger', onClick: @onLoadTrelloBoards, lang.getText('load-again')
    else
      div className: 'table-pair',
        div className: 'attr',
          div className: 'title', lang.getText('project-name')
          div className: 'about muted', lang.getText('on-select-project')
        div className: 'value',
          @renderBoards()

  render: ->
    div className: 'inte-trello inte-board lm-content',
      @renderInteHeader()
      @renderTopicRow()
      @renderTopicCreate()
      @renderBoardsSelector()
      @renderAccount()
      @renderInteTitle()
      @renderInteDesc()
      @renderInteIcon()
      if @props.inte?
        @renderInteModify()
      else
        @renderInteCreate()

  _getTrelloAccount: ->
    Q.Promise (resolve, reject) =>
      account = @props.accounts.find (v) -> v.get('refer') is 'trello'
      if account?
        @setState
          trelloAccount: account
          hasTrelloAccount: true
          , ->
            resolve()
      else
        @setState
          hasTrelloAccount: false
          , ->
            reject()
      return

  _getTrelloBoards: ->
    Q api.get "#{config.apiHost}/services/api/trello/getBoards"
