React = require 'react'
cx    = require 'classnames'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
query = require '../query'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'

messageActions = require '../actions/message'
orders = require '../util/orders'
search = require '../util/search'
detect = require '../util/detect'

SearchList = React.createFactory require '../app/search-list'

{ div, span, input } = React.DOM

T  = React.PropTypes
l  = lang.getText

module.exports = React.createClass
  displayName: 'forward-menu'
  mixins: [ mixinQuery, mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    onClose: T.func.isRequired
    onTeamSwitchClick: T.func.isRequired
    message: T.instanceOf(Immutable.Map)

  getInitialState: ->
    _roomIds: Immutable.List()
    _contactIds: Immutable.List()
    team: @getTeam()
    rooms: @getInitialTopics()
    contacts: @getInitialContacts()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        team: @getTeam()
        rooms: @getInitialTopics()
        contacts: @getInitialContacts()

  getInitialTopics: ->
    @getRooms().filter (topic) ->
      detect.inChannel(topic) and not topic.get('isArchived')

  getInitialContacts: ->
    @getContacts().filter (contact) =>
      contact.get('_id') isnt @props._userId

  onSubmit: ->
    _messageId = @props.message.get('_id')
    _teamId = @props._teamId
    @state._roomIds.forEach (_roomId) ->
      messageActions.messageForward {_messageId, _teamId, _roomId: _roomId}
    @state._contactIds.forEach (_contactId) ->
      messageActions.messageForward {_messageId, _teamId, _toId: _contactId}
    @props.onClose()

  onTopicClick: (topic) ->
    _roomIds = @state._roomIds
    _thisId = topic.get '_id'
    if _roomIds.includes _thisId
      _roomIds = _roomIds.filter (_roomId) -> _roomId isnt _thisId
    else
      _roomIds = _roomIds.push _thisId
    @setState { _roomIds }

  onContactClick: (contact) ->
    _contactIds = @state._contactIds
    _thisId = contact.get '_id'
    if _contactIds.includes _thisId
      _contactIds = _contactIds.filter (_contactId) -> _contactId isnt _thisId
    else
      _contactIds = _contactIds.push _thisId
    @setState { _contactIds }

  renderFooter: ->
    if @state._roomIds.size + @state._contactIds.size > 0
      value = l('forward-number').replace('%s', @state._roomIds.size + @state._contactIds.size)
    else
      value = l('forward')

    div className: 'footer',
      span className: 'button', onClick: @onSubmit, value

  renderTeamHint: ->
    div className: 'team-hint flex-static flex-horiz flex-vcenter flex-between',
      span className: 'muted', "#{l('forward-menu-team')}#{l('colon')}#{@state.team.get('name')}"
      span className: 'button is-link', onClick: @props.onTeamSwitchClick, l('forward-menu-team-switch')

  renderSearchList: ->
    SearchList
      _teamId: @props._teamId
      contacts: @state.contacts
      rooms: @state.rooms
      selectedContacts: @state._contactIds
      selectedRooms: @state._roomIds
      onContactClick: @onContactClick
      onRoomClick: @onTopicClick
      locale: l('search-for-channel')
      placeholder: l('no-matching-results')

  render: ->
    div className: 'forward-menu flex-vert',
      @renderTeamHint()
      @renderSearchList()
      @renderFooter()
