React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'

lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

search = require '../util/search'

InteItem = React.createFactory require './inte-item'

Transition = React.createFactory require '../module/transition'
TopicCorrection = React.createFactory require './topic-correction'

LiteSearchBox = React.createFactory require('react-lite-misc').SearchBox

hr  = React.createFactory 'hr'
div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'inte-manager'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId:  T.string.isRequired
    _roomId:  T.string.isRequired
    onEdit:   T.func.isRequired
    settings: T.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    integrations: @getIntes()
    topics: @getTopics()
    contacts: @getContacts()
    query: ''

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        integrations: @getIntes()
        topics: @getTopics()
        contacts: @getContacts()

  getIntes: ->
    query.intesBy(recorder.getState(), @props._teamId) or Immutable.List()

  getTopics: ->
    query.topicsBy(recorder.getState(), @props._teamId) or Immutable.List()

  getContacts: ->
    query.contactsBy(recorder.getState(), @props._teamId) or Immutable.List()

  detectShowRobot: (service) ->
    category = service.get('category')
    usingSetting = @props.settings.find (setting) ->
      setting.get('name') is category
    if usingSetting?
      usingSetting.get('showRobot')
    else false

  onInteEdit: (data) ->
    @props.onEdit data

  onQueryChange: (value) ->
    @setState query: value

  renderIntegrations: (integrations) ->
    Transition transitionName: 'fade', enterTimeout: 200, leaveTimeout: 350,
      integrations.map (service) =>
        showRobot = @detectShowRobot service
        InteItem key: service.get('_id'), data: service, onClick: @onInteEdit, showRobot: showRobot

  renderGroup: (group) ->
    div key: group.getIn(['room', '_id']),
      div className: 'topic short',
        '#'
        TopicCorrection
          topic: group.get('room')
      div className: 'service',
        @renderIntegrations group.get('integrations')

  render: ->
    _userId = query.userId(recorder.getState())
    userContact = @state.contacts.find (contact) ->
      contact.get('_id') is _userId
    isAdmin = userContact?.get('role') in ['owner', 'admin']
    searchLocale = lang.getText('find-by-name-or-service')

    integrations = search.inteItems @state.integrations, @state.query, @state.topics
    modifiedIntes = integrations.map (inte) ->
      inte.set 'canEdit', (inte.get('_creatorId') is _userId) or isAdmin

    integrationRobot = modifiedIntes.filter (inte) ->
      inte.get('robot')?
    integrationWithoutRobot = modifiedIntes.filterNot (inte) ->
      inte.get('robot')?

    integrationData = integrationWithoutRobot.groupBy (inte) ->
      inte.get('_roomId')
    integrationData = integrationData.map (list, _roomId) =>
      Immutable.fromJS
        room: @state.topics.find (topic) -> topic.get('_id') is _roomId
        integrations: list
    # integrations of private topic may cause bug
    integrationData = integrationData.filter (group) ->
      group.get('room')?

    currentGroup = integrationData.filter (data) =>
      data.getIn(['room', '_id']) is @props._roomId
    otherGroups = integrationData.filterNot (data) =>
      data.getIn(['room', '_id']) is @props._roomId

    div className: 'inte-manager lm-content',
      div className: 'filter',
        LiteSearchBox value: @state.query, onChange: @onQueryChange, locale: searchLocale, autoFocus: false

      if @props._roomId?
        if currentGroup.get(@props._roomId)?
          @renderGroup currentGroup.get(@props._roomId)
        else
          div null,
            div className: 'muted service-empty', lang.getText('current-service-empty')
            hr className: 'divider-thin'

      div className: 'modal-paragraph',
        if integrationRobot.get(0)?
          div null,
            div className: 'topic short', lang.getText('custom-robot')
            div className: 'service',
              @renderIntegrations integrationRobot
        if otherGroups.size > 0
          otherGroups
            .map (group) => @renderGroup group
            .toList()
        else
          div className: 'muted service-empty', lang.getText('service-empty')
