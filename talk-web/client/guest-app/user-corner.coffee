React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'
lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

time = require '../util/time'
dispatcher = require '../dispatcher'

userActions = require '../actions/user'

# components
UserMenu = React.createFactory require './user-menu'
SettingsProfile = React.createFactory require './settings-profile'

MemberCard  = React.createFactory require '../app/member-card'
LitePopover = React.createFactory require 'react-lite-layered/lib/popover'
LiteModal   = React.createFactory require 'react-lite-layered/lib/modal'

div = React.createFactory 'div'
hr  = React.createFactory 'hr'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'user-corner'
  mixins: [mixinSubscribe]

  propTypes:
    _teamId: T.string.isRequired

  getInitialState: ->
    user: @getUser()
    showMenu: false
    showSettings: false

  componentDidMount: ->
    @_rootEl = @refs.root
    @subscribe recorder, =>
      @setState user: @getUser()

  getUser: ->
    query.user(recorder.getState())

  getBaseArea: ->
    if @_rootEl?
      @_rootEl.getBoundingClientRect()
    else
      {}

  # event handlers

  onAvatarClick: (event) ->
    event.stopPropagation()
    @setState showMenu: (not @state.showMenu)

  onPopoverClose: (event) ->
    @setState showMenu: false

  onSettingsClick: ->
    @setState showSettings: true

  onSettingsClose: ->
    @setState showSettings: false

  onLogoutClick: ->
    userActions.userSignout()

  renderMenu: ->
    LitePopover
      baseArea: if @state.showMenu then @getBaseArea() else {}
      onPopoverClose: @onPopoverClose
      showClose: false
      show: @state.showMenu
      name: 'user-corner'
      UserMenu
        onSettingsClick: @onSettingsClick
        onVersionClick: @onVersionClick
        onLogoutClick: @onLogoutClick
        onPopoverClose: @onPopoverClose

  renderSettings: ->
    LiteModal
      title: lang.getText('user-preferences')
      onCloseClick: @onSettingsClose
      show: @state.showSettings
      SettingsProfile data: @state.user, onModalClose: @onSettingsClose

  render: ->

    avatarStyle =
      backgroundImage: "url('#{@state.user.get('avatarUrl')}')"

    div ref: 'root', className: 'user-corner',
      div
        className: 'img-circle avatar img-36'
        style: avatarStyle
        onClick: @onAvatarClick
      @renderMenu()
      @renderSettings()
