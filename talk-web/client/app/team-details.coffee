React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'
lang    = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

TeamContacts  = React.createFactory require '../app/team-contacts'
TeamSettings  = React.createFactory require '../app/team-settings'
SwitchTabs    = React.createFactory require('react-lite-misc').SwitchTabs

Permission = require '../module/permission'
TeamConfigsClass = require '../app/team-configs'
TeamConfigsPermission = React.createFactory Permission.create(TeamConfigsClass, Permission.admin, Permission.mode.propogate)

div = React.createFactory 'div'

T = React.PropTypes
tabs = ['team-configs', 'team-contacts', 'advanced-settings']

module.exports = React.createClass
  displayName: 'team-details'
  mixins: [mixinSubscribe]

  propTypes:
    tab:      T.oneOf tabs
    _teamId:  T.string.isRequired
    onClose:  T.func.isRequired
    router: T.instanceOf(Immutable.Map)

  getInitialState: ->
    tab: @props.tab or tabs[0]
    user: @getUser()
    contacts: @getContacts()
    team: @getTeam()
    invitations: @getInvitations()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        user: @getUser()
        team: @getTeam()
        contacts: @getContacts()
        invitations: @getInvitations()

  getUser: ->
    query.user(recorder.getState())

  getTeam: ->
    query.teamBy(recorder.getState(), @props._teamId)

  getContacts: ->
    query.contactsBy(recorder.getState(), @props._teamId) or Immutable.List()

  getInvitations: ->
    query.invitationsBy(recorder.getState(), @props._teamId) or Immutable.List()

  detectPermission: ->
    _userId = @state.user.get('_id')
    one = @state.contacts.find (contact) ->
      contact.get('_id') is _userId and contact.get('role') in ['admin', 'owner']
    one?

  onClick: (event) ->
    event.stopPropagation()

  onTabClick: (tab) -> @setState tab: tab

  onSwitchSettingTab: -> @setState tab: tabs[2]

  render: ->

    hasPermission = @detectPermission()

    div className: 'team-details', onClick: @onClick,
      SwitchTabs
        data: tabs, tab: @state.tab
        onTabClick: @onTabClick
        getText: lang.getText
      switch @state.tab
        when tabs[0]
          TeamConfigsPermission
            _teamId: @props._teamId
            data: @state.team
            onClose: @props.onClose
        when tabs[1]
          TeamContacts
            data: @state.contacts
            team: @state.team
            user: @state.user
            router: @props.router
            invitations: @state.invitations
            onSwitchTab: @onSwitchSettingTab
        when tabs[2]
          TeamSettings
            data: @state.team
