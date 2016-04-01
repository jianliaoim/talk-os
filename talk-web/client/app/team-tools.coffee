cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'

lang = require '../locales/lang'
analytics = require '../util/analytics'

routerHandlers = require '../handlers/router'

mixinRouter = require '../mixin/router'

Icon = React.createFactory require '../module/icon'
Tooltip = React.createFactory require '../module/tooltip'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ a, div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-tools'
  mixins: [mixinRouter, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    router: T.instanceOf(Immutable.Map).isRequired

  onRouteCollection: ->
    if @isActiveRoute 'collection'
      routerHandlers.return()
      return
    routerHandlers.collection @props._teamId
    analytics.openSearch()

  onRouteOverview: ->
    if @isActiveRoute 'overview'
      routerHandlers.return()
      return
    routerHandlers.teamOverview @props._teamId
    analytics.openOverview()

  onRouteFavorites: ->
    if @isActiveRoute 'favorites'
      routerHandlers.return()
      return
    routerHandlers.favorites @props._teamId

  onRouteMentions: ->
    if @isActiveRoute 'mentions'
      routerHandlers.return()
      return

    params =
      _teamId: @props._teamId
    routerHandlers.mentions params

  onRouteTags: ->
    if @isActiveRoute 'tags'
      routerHandlers.return()
      return
    routerHandlers.tags @props._teamId

  render: ->
    div className: 'team-tools',
      Tooltip template: lang.getText('activities'),
        a className: cx('btn-tool', 'active': @isActiveRoute 'overview'), onClick: @onRouteOverview,
          Icon name: 'activity', size: 18
      Tooltip template: lang.getText('mentioned-me'),
        a className: cx('btn-tool', 'active': @isActiveRoute 'mentions'), onClick: @onRouteMentions,
          Icon name: 'at', size: 18
      Tooltip template: lang.getText('search'),
        a className: cx('btn-tool', 'active': @isActiveRoute 'collection'), onClick: @onRouteCollection,
          Icon name: 'search', size: 18
      Tooltip template: lang.getText('tag'),
        a className: cx('btn-tool', 'active': @isActiveRoute 'tags'), onClick: @onRouteTags,
          Icon name: 'tag', size: 18
      Tooltip template: lang.getText('collection'),
        a className: cx('btn-tool', 'active': @isActiveRoute 'favorites'), onClick: @onRouteFavorites,
          Icon name: 'star', size: 18
