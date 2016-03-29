React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

mixinSubscribe = require '../mixin/subscribe'

ChannelBody = React.createFactory require './channel-body'
ChannelHeader = React.createFactory require './channel-header'
LoadingIndicator = React.createFactory require('react-lite-misc').LoadingIndicator

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'channel-page'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    _channelId: T.string
    _channelType: T.string.isRequired
    routerQuery: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    @getState()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState(@getState())

  getState: ->
    prefs: query.prefs recorder.getState()
    channel: (query.byChannelType @props._channelType) recorder.getState(), @props._teamId, @props._channelId
    members: query.membersBy recorder.getState(), @props._teamId, @props._channelId
    contacts: query.contactsBy recorder.getState(), @props._teamId
    messages: query.messagesBy recorder.getState(), @props._teamId, @props._channelId
    notification: query.notificationsByOne recorder.getState(), @props._teamId, @props._channelId
    notifyBanner: query.bannerNotices(recorder.getState())
    draftMessage: query.draftMessageBy recorder.getState(), @props._teamId, @props._channelId
    isLoading: @isLoading()

  isLoading: ->
    loadingStack = query.deviceLoadingStack(recorder.getState())
    return false if loadingStack.size is 0
    loadingType = loadingStack.first().get('type')
    Immutable.List(['topic', 'story', 'contact']).includes(loadingType)

  render: ->
    if @state.isLoading
      LoadingIndicator()
    else if @state.channel and not @state.channel.isEmpty()
      div className: 'channel-page flex-space flex-vert',
        ChannelHeader
          _teamId: @props._teamId
          _userId: @props._userId
          _channelId: @props._channelId
          _channelType: @props._channelType
          prefs: @state.prefs
          channel: @state.channel
          members: @state.members
          contacts: @state.contacts
          notification: @state.notification
        ChannelBody
          _teamId: @props._teamId
          _userId: @props._userId
          _channelId: @props._channelId
          _channelType: @props._channelType
          routerQuery: @props.routerQuery
          channel: @state.channel
          contacts: @state.contacts
          messages: @state.messages
          notification: @state.notification
          notifyBanner: @state.notifyBanner
          draft: @state.draftMessage
    else
      null
