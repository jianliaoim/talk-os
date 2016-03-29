React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'

mixinRouter = require '../mixin/router'

TagPage = React.createFactory require './tag-page'
ChannelPage = React.createFactory require './channel-page'
MentionsPage = React.createFactory require './mentions-page'
FavoritesPage = React.createFactory require './favorites-page'
CollectionPage = React.createFactory require './collection-page'

{ div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-wrapper'
  mixins: [ mixinRouter, PureRenderMixin ]

  propTypes:
    _toId: T.string
    _roomId: T.string
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    _storyId: T.string
    _channelId: T.string
    _channelType: T.string
    user: T.instanceOf(Immutable.Map).isRequired

  renderPage: ->
    switch @getRouteName()
      when 'chat', 'room', 'story'
        ChannelPage
          _teamId: @props._teamId
          _userId: @props._userId
          _channelId: @props._channelId
          _channelType: @props._channelType
          key: @props._channelId
          routerQuery: @props.router.get('query')

      when 'tags'
        TagPage
          _teamId: @props._teamId
          router: @props.router

      when 'favorites'
        FavoritesPage
          _teamId: @props._teamId
          router: @props.router

      when 'collection'
        CollectionPage
          router: @props.router

      when 'mentions'
        MentionsPage
          _teamId: @props._teamId
          router: @props.router
          className: 'flex-space'
      else
        null

  render: ->
    div className: 'team-wrapper flex-horiz flex-space',
      @renderPage()
