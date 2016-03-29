React = require 'react'
Immutable = require 'immutable'

lang = require '../locales/lang'

SettingRookie = React.createFactory require './setting-rookie'
SettingSync = React.createFactory require './setting-sync'
SettingSyncTeams = React.createFactory require './setting-sync-teams'
SettingTeamCreate = React.createFactory require './setting-team-create'
SettingTeams = React.createFactory require './setting-teams'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'setting-page'
  mixins: [PureRenderMixin]

  propTypes:
    router: T.instanceOf(Immutable.Map).isRequired

  renderPage: ->
    switch @props.router.get('name')
      when 'setting-rookie'
        SettingRookie()
      when 'setting-sync'
        SettingSync()
      when 'setting-sync-teams'
        SettingSyncTeams()
      when 'setting-team-create'
        SettingTeamCreate()
      when 'setting-teams'
        SettingTeams()
      else
        null

  render: ->
    div className: 'setting-page thin-scroll',
      div className: "site-logo is-#{ lang.getLang() }"
      div className: 'content',
        @renderPage()
