React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'

settingsActions = require '../actions/settings'

routerHandlers = require '../handlers/router'

mixinRouter = require '../mixin/router'

TourGuide = require '../tour-guide/index'

TeamDrawer = React.createFactory require './team-drawer'
TeamHeader = React.createFactory require './team-header'
TeamSidebar = React.createFactory require './team-sidebar'
TeamToolbar = React.createFactory require './team-toolbar'
TeamWrapper = React.createFactory require './team-wrapper'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div } = React.DOM
T = React.PropTypes

# mounted to router
module.exports = React.createClass
  displayName: 'team-page'
  mixins: [mixinRouter, PureRenderMixin]

  componentDidMount: ->
    webData = @props.store.getIn(['user', 'preference', 'webData'])?.toJS()
    router = @props.store.get('router')
    if not webData?
      if router.get('name') not in ['chat', 'room', 'story']
        _teamId = router.getIn(['data', '_teamId'])
        _latestTeamId = @props.store.getIn(['prefs', '_latestTeamId'])
        routerHandlers.team _teamId or _latestTeamId
        TourGuide.start webData
      else
        TourGuide.start webData

  getUserId: ->
    query.userId @props.store

  render: ->
    _userId = @getUserId()
    _teamId = @getTeamId()
    _channelId = @getChannelId()
    channelType = @getChannelType()

    div className: 'team-page flex-horiz',
      div className: 'team-aside flex-vert',
        TeamHeader
          _teamId: _teamId
          team: query.teamBy @props.store, _teamId
          teams: query.teams @props.store
          router: @props.router
        TeamSidebar
          _teamId: _teamId
          _channelId: _channelId
          _channelType: channelType
      div className: 'team-main flex-space flex-vert',
        TeamToolbar
          _teamId: _teamId
          user: query.user @props.store
          router: @props.router
        TeamWrapper
          #
          # _toId, _roomId, _storyId is not a very common property,
          # those will be removed someday.
          #
          _toId: @getChannelId '_toId'
          _roomId: @getChannelId '_roomId'
          _teamId: @getTeamId()
          _userId: _userId
          _storyId: @getChannelId '_storyId'
          _channelId: _channelId
          _channelType: channelType
          user: query.user @props.store
          router: @props.router
        TeamDrawer
          _teamId: _teamId
          _userId: _userId
          channelType: channelType
          channel: query.byChannelType(channelType)?(@props.store, _teamId, _channelId)
          type: query.drawerStatus @props.store
