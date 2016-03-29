cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

settingsActions = require '../actions/settings'

dom = require '../util/dom'

DrawerStory = React.createFactory require './drawer-story'
ChannelCollection = React.createFactory require './channel-collection'
TeamDirectory = React.createFactory require './team-directory'

{ div, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-drawer'

  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    channel: T.instanceOf(Immutable.Map)
    type: T.oneOfType([T.string, T.bool]).isRequired

  getDefaultProps: ->
    type: false

  componentWillReceiveProps: (nextProps) ->
    if nextProps.type
      window.addEventListener 'click', @onWindowCloseDrawer
    else
      window.removeEventListener 'click', @onWindowCloseDrawer

  componentWillUnmount: ->
    window.removeEventListener 'click', @onWindowCloseDrawer

  shouldDrawerClose: ->
    return true if not @props.channel? or @props.channel.isEmpty()
    switch @props.type
      when 'story'
        if @props.channelType isnt 'story' then return true
      when 'collection'
        if @props.channel.get('isQuit') then return true

  onWindowCloseDrawer: (event) ->
    inApp = dom.isNodeInRoot event.target, document.querySelector '.app-container'
    inDrawer = dom.isNodeInRoot event.target, @refs.root

    if not inDrawer and inApp
      settingsActions.closeDrawer()

  renderTeamDirectory: ->
    TeamDirectory
      _teamId: @props._teamId
      _userId: @props._userId

  renderDrawerStory: ->
    DrawerStory
      _teamId: @props._teamId
      _userId: @props._userId
      story: @props.channel

  renderCollection: ->
    ChannelCollection
      _teamId: @props._teamId
      _channelId: @props.channel.get('_id')
      _channelType: @props.channelType

  render: ->
    return null if @shouldDrawerClose()
    div ref: 'root', className: cx('team-drawer', 'is-open': @props.type),
      switch @props.type
        when 'story' then @renderDrawerStory()
        when 'member' then @renderTeamDirectory()
        when 'collection' then @renderCollection()
        else noscript()
