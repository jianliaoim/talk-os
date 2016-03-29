React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'

deviceActions = require '../actions/device'
notifyActions = require '../actions/notify'

routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

StoryName = React.createFactory require '../app/story-name'
TopicName = React.createFactory require '../app/topic-name'
ContactName = React.createFactory require '../app/contact-name'
FilterTopic = React.createFactory require '../app/filter-topic'
FilterContact = React.createFactory require '../app/filter-contact'

SearchBox = React.createFactory require('react-lite-misc').SearchBox

{ div, span } = React.DOM
T = React.PropTypes

module.exports =

  onMessageClick: (message) ->
    target = message.get '_targetId'
    if not target?
      notifyActions.error lang.getText 'null-target-message'
      return

    type = message.get 'type'
    if type is 'dms' then type = 'chat'
    team = message.get '_teamId'
    searchQuery =
      search: message.get('_messageId') or message.get('_id')

    routerHandlers[type] team, target, searchQuery

  onCreatorChange: (_creatorId) ->
    newState =
      _creatorId: _creatorId
      page: 1
      resultsEnd: false
    @clearResults()
    @setState newState, @sendSearchRequest

  onChannelChange: (_roomId, isDirectMessage) ->
    newState =
      _roomId: _roomId
      _storyId: undefined
      page: 1
      resultsEnd: false
      isDirectMessage: isDirectMessage
    @clearResults()
    @setState newState, @sendSearchRequest

  onQueryChange: (query) ->
    @setState query: query

  onQueryConfirm: (query) ->
    newState =
      page: 1
      resultsEnd: false
    @clearResults()
    @setState newState, @sendSearchRequest

  onFileClick: (attachment) ->
    @setState showFileQueue: true, cursorAttachment: attachment
    deviceActions.viewAttachment attachment.get('_id')

  onFileQueueHide: ->
    @setState showFileQueue: false
    deviceActions.viewAttachment null

  onScroll: (eventInfo) ->
    if eventInfo.atBottom and eventInfo.goingDown
      @sendSearchRequest()

  renderFilterContact: ->
    FilterContact
      _teamId: @props._teamId
      onChange: @onCreatorChange
      _creatorId: @state._creatorId

  renderFilterTopic: ->
    FilterTopic
      _teamId: @props._teamId
      isDirectMessage: @state.isDirectMessage
      _roomId: @state._roomId
      onChange: @onChannelChange

  renderSearchbox: ->
    SearchBox
      value: @state.query or ''
      onChange: @onQueryChange
      locale: lang.getText('type-keywords')
      autoFocus: false
      onConfirm: @onQueryConfirm

  renderHint: (message) ->
    switch message.get 'type'
      when 'dms' then @renderChatHint message
      when 'room' then @renderRoomHint message
      when 'story' then @renderStoryHint message

  renderChatHint: (message) ->
    div className: 'group',
      ContactName
        contact: message.get('to')
        _teamId: @props._teamId

  renderRoomHint: (message) ->
    div className: 'group',
      TopicName topic: message.get('room')

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
