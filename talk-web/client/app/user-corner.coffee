cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

userActions = require '../actions/user'

routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

TalkDownload = React.createFactory require './talk-download'
UserMenu = React.createFactory require './user-menu'
UserAlias = React.createFactory require './user-alias'
AboutFeedback = React.createFactory require './about-feedback'

Avatar = React.createFactory require '../module/avatar'

LiteModal = React.createFactory require '../module/modal-beta'
LitePopover = React.createFactory require '../module/popover-beta'

{ a, div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'UserCorner'
  mixins: [ PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    user: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showMenu: false
    showSettings: false
    showDownload: false
    showFeedback: false

  componentDidMount: ->
    @_roolEl = @refs.root

  getBaseArea: ->
    @_roolEl?.getBoundingClientRect() or {}

  getClassName: ->
    cx 'user-corner', 'flex-horiz flex-vcenter', 'row large'

  getPosition: (area) ->
    top: area.bottom - 2
    right: 24

  onAvatarClick: (event) ->
    event.stopPropagation()

    @setState showMenu: (not @state.showMenu)

  onPopoverClose: ->
    @setState showMenu: false

  onSettingsClick: ->
    routerHandlers.profile()

  onDownloadClick: ->
    @setState showDownload: true

  onFeedbackClick: ->
    @setState showFeedback: true

  onTalkInfoClose: ->
    @setState showDownload: false

  onFeedbackClose: ->
    @setState showFeedback: false

  onLogoutClick: ->
    userActions.userSignout()

  renderMenu: ->
    LitePopover
      name: 'user-corner'
      show: @state.showMenu
      baseArea: if @state.showMenu then @getBaseArea() else {}
      showClose: false
      onPopoverClose: @onPopoverClose
      positionAlgorithm: @getPosition
      UserMenu
        data: @props.user
        onSettingsClick: @onSettingsClick
        onDownloadClick: @onDownloadClick
        onLogoutClick: @onLogoutClick
        onPopoverClose: @onPopoverClose
        onFeedbackClick: @onFeedbackClick

  renderTalkInfo: ->
    LiteModal
      name: 'talk-download'
      show: @state.showDownload
      title: lang.getText 'download-apps'
      onCloseClick: @onTalkInfoClose
      TalkDownload()

  renderFeedback: ->
    LiteModal
      title: lang.getText('feedback')
      onCloseClick: @onFeedbackClose
      show: @state.showFeedback
      AboutFeedback()

  render: ->
    a ref: 'root', className: @getClassName(), onClick: @onAvatarClick,
      Avatar src: @props.user.get('avatarUrl'), size: 'normal', shape: 'round'
      @renderMenu()
      @renderTalkInfo()
      @renderFeedback()
