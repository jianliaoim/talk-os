React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
cx = require 'classnames'

lang = require '../locales/lang'

query = require '../query'

mixinSubscribe = require '../mixin/subscribe'
mixinQuery = require '../mixin/query'

settingsActions = require '../actions/settings'

MemberBoard = React.createFactory require './member-board'
GroupBoard = React.createFactory require './group-board'
Icon = React.createFactory require '../module/icon'

{ a, div, noscript } = React.DOM
T = React.PropTypes

tabInfo = [
  { name: "team-contacts", tab: 'members' }
  { name: 'team-groups', tab: 'groups' }
]

module.exports = React.createClass
  displayName: 'team-directory'

  mixins: [ mixinQuery, mixinSubscribe ]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    onClose: T.func

  getInitialState: ->
    tab: 'members'
    groups: @getGroups()
    contacts: @getContacts()
    invitations: @getInvitations()
    leftContacts: @getLeftContacts()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        groups: @getGroups()
        contacts: @getContacts()
        invitations: @getInvitations()
        leftContacts: @getLeftContacts()

  getNum: (tab) ->
    number =
      switch tab
        when 'members'
          @state.contacts.size + @state.invitations.size
        when 'groups'
          @state.groups.size

    if number > 0 then "(#{number})" else ''

  onTabClick: (tab) ->
    @setState tab: tab

  closeTeamDrawer: ->
    settingsActions.closeDrawer()

  renderHeader: ->
    div className: 'header',
      div className: 'content flex-horiz',
        tabInfo.map (tab, index) =>
          cxTab = cx 'tab', 'flex-fill', 'is-active': ( tab.tab is @state.tab )

          div className: cxTab, key: index, onClick: ( => @onTabClick tab.tab ), "#{lang.getText(tab.name)} #{@getNum(tab.tab)}"
        Icon name: 'remove', size: 20, onClick: @closeTeamDrawer, className: 'flex-static muted'

  renderBody: ->
    div className: 'body flex-vert flex-fill',
      switch @state.tab
        when 'members'
          MemberBoard
            _teamId: @props._teamId
            _userId: @props._userId
            contacts: @state.contacts
            invitations: @state.invitations
            leftContacts: @state.leftContacts
        when 'groups'
          GroupBoard
            _teamId: @props._teamId
            _userId: @props._userId
            groups: @state.groups
            contacts: @state.contacts

  render: ->
    div className: 'team-directory flex-vert',
      @renderHeader()
      @renderBody()
