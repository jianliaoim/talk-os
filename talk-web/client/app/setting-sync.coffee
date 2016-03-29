cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'
teamActions = require '../actions/team'
accountActions = require '../actions/account'
notifyActions = require '../actions/notify'
routerHandlers = require '../handlers/router'

mixinSubscribe = require '../mixin/subscribe'

lang = require '../locales/lang'

LiteNewModal = React.createFactory require '../module/new-modal'

a = React.createFactory 'a'
i = React.createFactory 'i'
div = React.createFactory 'div'
span = React.createFactory 'span'

module.exports = React.createClass
  displayName: 'setting-sync'
  mixins: [mixinSubscribe]

  getInitialState: ->
    unions: @getAccounts()
    showWarning: false

  componentDidMount: ->
    @subscribe recorder, =>
      @setState unions: @getAccounts()

  getAccounts: ->
    query.accounts(recorder.getState())

  onBack: ->
    routerHandlers.settingTeams()

  onTeamListShow: ->
    routerHandlers.teamSyncList()

  onBind: -> accountActions.bind 'teambition'

  renderSync: ->
    div className: 'content',
      div className: 'sync-logo sync-teambition'
      span className: 'intro', lang.getText 'sync-from-teambition'
      div className: 'bottom',
        a onClick: @onTeamListShow, lang.getText 'sync-team'

  renderBind: ->
    div className: 'content',
      div className: 'sync-logo sync-teambition'
      span className: 'intro', lang.getText 'sync-from-teambition'
      div className: 'bottom',
        a onClick: @onBind, lang.getText 'bind-teambition'

  render: ->
    isTeambition = @state.unions.some (union) ->
      union.get('login') is 'teambition'

    div className: 'setting-sync setting-wrapper',
      div className: 'header',
        i className: 'icon icon-td-arrow-left to-back', onClick: @onBack
        lang.getText 'setting-team-sync'
      if isTeambition
        @renderSync()
      else
        @renderBind()
