React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
handlers = require '../handlers'

inteActions = require '../actions/inte'
settingsActions = require '../actions/settings'

lang = require '../locales/lang'
analytics = require '../util/analytics'

mixinSubscribe = require '../mixin/subscribe'

InteList = React.createFactory require './inte-list'
InteHooks = React.createFactory require './inte-hooks'
InteManager = React.createFactory require './inte-manager'

# each integration thing
InteRss = React.createFactory require './inte-rss'
InteForm = React.createFactory require './inte-form'
InteEmail = React.createFactory require './inte-email'
InteWeibo = React.createFactory require './inte-weibo'
InteGithub = React.createFactory require './inte-github'
InteTrello = React.createFactory require './inte-trello'
InteWebhook = React.createFactory require './inte-webhook'
InteTeambition = React.createFactory require './inte-teambition'

Icon  = React.createFactory require '../module/icon'

LiteSwitchTabs = React.createFactory require('react-lite-misc').SwitchTabs
LiteLoadingIndicator = React.createFactory require('react-lite-misc').LoadingIndicator

a = React.createFactory 'a'
div = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

tabs = ['add-service', 'custom-service', 'manage-service']
tabIcons =
  'add-service': 'plus',
  'custom-service': 'edit',
  'manage-service': 'cog-solid'

module.exports = React.createClass
  displayName: 'inte-page'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _roomId: T.string
    settings: T.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    tab: tabs[0]
    topic: @getTopic()
    team: @getTeam()
    showInteBanner: @getShowInteBanner()
    category: null
    activeInte: null
    accounts: @getAccounts()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        team: @getTeam()
        topic: @getTopic()
        showInteBanner: @getShowInteBanner()
        accounts: @getAccounts()

  getTeam: ->
    query.teamBy(recorder.getState(), @props._teamId)

  getTopic: ->
    query.topicsByOne(recorder.getState(), @props._teamId, @props._roomId)

  getShowInteBanner: ->
    query.settings(recorder.getState()).get('showInteBanner')

  getAccounts: ->
    recorder.getState().getIn ['accounts'] or Immutable.List()

  # methods

  # events

  onClose: ->
    handlers.router.back()

  onTabClick: (tab) ->
    @setState tab: tab
    switch tab
      when 'add-service' then analytics.openAddService()
      when 'custom-service' then analytics.openCustomIntegration()
      when 'manage-service' then analytics.openEditIntegration()

  onPageSwitch: (category) ->
    @setState category: category

  onPageBack: (fromState) ->
    if fromState
      targetTab = tabs[2]
    else
      targetTab = tabs[0]
    @setState category: null, tab: targetTab, activeInte: null

  onInteEdit: (data) ->
    @setState activeInte: data, category: data.get('category')

  onBannerHide: ->
    settingsActions.update showInteBanner: false

  # renderers

  renderBanner: ->
    div className: 'inte-banner',
      div className: 'mask', lang.getText('integrations-banner')
      span className: 'ti ti-remove', onClick: @onBannerHide

  renderLists: ->
    onClick = ->
    thirdPartyIntes = @props.settings.filter (value, key) ->
      not value.get('isCustomized')
    customizedIntes = @props.settings.filter (value, key) ->
      value.get('isCustomized')

    div className: 'page',
      LiteSwitchTabs
        data: tabs, tab: @state.tab, iconMap: tabIcons
        getText: lang.getText
        onTabClick: @onTabClick
      switch @state.tab
        when 'add-service'
          InteList onPageSwitch: @onPageSwitch, intes: thirdPartyIntes, _teamId: @props._teamId, _roomId: @props._roomId, onPageBack: @onPageBack
        when 'custom-service'
          InteHooks onPageSwitch: @onPageSwitch, intes: customizedIntes
        when 'manage-service'
          InteManager _roomId: @state.topic.get('_id'), _teamId: @props._teamId, onEdit: @onInteEdit, settings: @props.settings

  renderView: ->
    surveyLink = 'https://jinshuju.net/f/V3VeJ7'

    div className: 'view',
      @renderLists()
      div className: 'sidebar',
        div className: 'feedback-survey',
          span className: 'tip-guide', lang.getText('wish-talk')
          a href: surveyLink, target: '_blank', lang.getText('join-survey')

  renderPage: ->
    pageProps =
      _teamId: @props._teamId
      _roomId: @state.topic.get('_id')
      onPageBack: @onPageBack
      inte: @state.activeInte
      onInteEdit: @onInteEdit
      accounts: @state.accounts

    settings = @props.settings.find (config) =>
      config.get('name') is @state.category
    pageProps.settings = settings

    switch settings?.get('template')
      # 'firim', 'gitlab', 'coding', 'jinshuju', 'incoming', 'jiankongbao'
      when 'webhook' then InteWebhook pageProps
      when 'form' then InteForm pageProps
      else
        switch @state.category
          when 'weibo'  then InteWeibo  pageProps
          when 'rss'    then InteRss    pageProps
          when 'github' then InteGithub pageProps
          when 'teambition' then InteTeambition pageProps
          when 'email' then InteEmail pageProps
          when 'trello' then InteTrello pageProps
          else lang.getText('error')

  render: ->
    bodyStyle =
      height: "#{window.innerHeight - 60}px"

    div className: 'inte-page',
      div className: 'header pageview-header',
        div className: 'name', @state.team.get('name')
        div className: 'title line flex-horiz flex-vcenter',
          span className: 'ti ti-square'
          lang.getText('integrations')
        Icon name: 'remove', size: 24, className: 'button-close is-white', onClick: @onClose
      div className: 'body', style: bodyStyle,
        if @state.showInteBanner
          @renderBanner()
        if @state.category
          @renderPage()
        else
          @renderView()
