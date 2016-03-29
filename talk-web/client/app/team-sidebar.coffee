React = require 'react'
debounce = require 'debounce'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'

lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

dom = require '../util/dom'

InboxTable = React.createFactory require './inbox-table'

{ div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-sidebar'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _channelId: T.string
    _channelType: T.string

  getInitialState: ->
    contacts: @getContacts()
    topics: @getTopics()
    notifications: @getNotifications()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        contacts: @getContacts()
        topics: @getTopics()
        notifications: @getNotifications()

  getContacts: ->
    query.contactsBy recorder.getState(), @props._teamId

  getTopics: ->
    query.topicsBy recorder.getState(), @props._teamId

  getNotifications: ->
    query.notificationsBy recorder.getState(), @props._teamId

  renderInbox: ->
    InboxTable
      _teamId: @props._teamId
      _channelId : @props._channelId
      _channelType: @props._channelType

  render: ->
    div className: 'team-sidebar flex flex-space',
      @renderInbox()
