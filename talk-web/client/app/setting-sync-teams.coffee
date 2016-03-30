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

LightModal = React.createFactory require '../module/light-modal'
Icon = React.createFactory require '../module/icon'

i = React.createFactory 'i'
div = React.createFactory 'div'
span = React.createFactory 'span'
button = React.createFactory 'button'

l = lang.getText

module.exports = React.createClass
  displayName: 'setting-sync-teams'
  mixins: [mixinSubscribe]

  getInitialState: ->
    refer: 'teambition'
    teams: @getTeams()
    unions: @getAccounts()
    thirdPartyTeams: @getThirdPartyTeams()
    showConfirmBox: false

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        unions: @getAccounts()
        thirdPartyTeams: @getThirdPartyTeams()
        teams: @getTeams()

  getAccounts: ->
    query.accounts(recorder.getState())

  getTeams: ->
    query.teams(recorder.getState())

  getThirdPartyTeams: ->
    query.thirdParties(recorder.getState())

  hasSynced: (sourceId) ->
    @state.teams.find (team) ->
      team.get('sourceId') is sourceId

  gotoSyncedTeam: (_teamId) ->
    routerHandlers.team(_teamId)

  onBack: ->
    routerHandlers.teamSync()

  onConfirmBoxShow: (team) ->
    @setState
      showConfirmBox: true
      targetTeam: team

  onConfirmBoxClose: ->
    @setState showConfirmBox: false

  onTeamSyncone: ->
    data =
      refer: @state.refer
      sourceId: @state.targetTeam?.get('sourceId')
    teamActions.syncOne data,
      =>
        notifyActions.success lang.getText 'sync-success'
        @onConfirmBoxClose()
      =>
        notifyActions.success lang.getText 'sync-fail'
        @onConfirmBoxClose()

  onSync: ->
    teamActions.sync 'teambition',
      (res) ->
        if res.length and res.some((team) -> team.source?.length)
          notifyActions.success lang.getText 'sync-success'
        else
          notifyActions.info lang.getText 'no-teambition-team'
        routerHandlers.settingTeams()
      ->
        notifyActions.success lang.getText 'sync-fail'

  renderConfirmBox: ->
    LightModal
      name: 'sync-team'
      show: @state.showConfirmBox
      title: lang.getText 'sync-team'
      onCloseClick: @onConfirmBoxClose,
        div className: 'profile-wrapper',
          div className: 'warning',
            l('sync-team-warning').replace('%s', @state.targetTeam?.get('name'))
          button className: 'button is-primary', onClick: @onTeamSyncone, lang.getText 'confirm'

  renderTeamList: ->
    if @state.thirdPartyTeams.get(@state.refer).size is 0
      div className: 'placeholder muted',
        l('sync-teambition-placeholder')
    else
      @state.thirdPartyTeams.get(@state.refer).map (team) =>
        syncedTeam = @hasSynced(team.get('sourceId'))
        cxAction = cx 'action', 'button', 'is-small', (if syncedTeam? then 'is-link' else 'is-primary'),
          'syncone': not syncedTeam?
        btnText = if syncedTeam then l('team-syncone-again') else l('team-syncone')

        onSyncClick = => @onConfirmBoxShow(team)

        div className: 'team list line',
          span className: 'name', team.get('name')
          button className: cxAction, onClick: onSyncClick, btnText
          if syncedTeam
            _teamId = syncedTeam.get('_id')
            gotoSyncedTeam = => @gotoSyncedTeam(_teamId)

            div className: 'goto', onClick: gotoSyncedTeam,
              i className: 'ti ti-arrow-left'

  renderTips: ->
    div className: 'tip-wrapper', l('teambition-sync-tip')

  render: ->
    div className: 'setting-sync-teams setting-wrapper',
      div className: 'header',
        Icon name: 'arrow-left', size: 24, className: 'to-back', onClick: @onBack
        lang.getText 'setting-team-sync'
      div className: 'team-list thin-scroll',
        @renderTeamList()
      @renderTips()
      @renderConfirmBox()
