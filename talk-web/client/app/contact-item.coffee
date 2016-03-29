React = require 'react'
Immutable = require 'immutable'
cx = require 'classnames'
recorder = require 'actions-recorder'

query = require '../query'

contactActions = require '../actions/contact'
teamActions = require '../actions/team'
notifyActions = require '../actions/notify'

detect = require '../util/detect'
search = require '../util/search'

lang = require '../locales/lang'

UserAlias = React.createFactory require './user-alias'
Icon = React.createFactory require '../module/icon'
Avatar = React.createFactory require '../module/avatar'

{ div, span } = React.DOM

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'contact-item'

  propTypes:
    _teamId: T.string
    contact: T.instanceOf(Immutable.Map)
    isInvite: T.bool
    showAction: T.bool
    onClick: T.func
    invitations: T.instanceOf(Immutable.List)

  getDefaultProps: ->
    showAction: true
    isInvite: false
    invitations: Immutable.List()

  isMe: ->
    _userId = query.userId(recorder.getState())
    @props.contact.get('_id') is _userId

  onClick: ->
    @props.onClick?()

  renderRobotIcon: ->
    return null if not detect.isRobot(@props.contact)
    span className: 'icon icon-talkai'

  renderQuitHint: ->
    if @props.contact.get('isQuit')
      span className: 'muted info flex-static', "#{l('contact-quitted')}"

  renderContact: ->
    cxItem = cx 'contact-item', 'flex-horiz', 'flex-vcenter', 'line', 'is-clickable': @props.onClick?
    role = if @props.isInvite then 'not-actived' else @props.contact.get('role')

    div className: cxItem, key: @props.contact.get('_id'), onClick: @onClick,
      div className: 'content flex-horiz flex-fill flex-vcenter line text-overflow',
        @renderAvatar()
        @renderBody()
        @renderQuitHint()
      if @props.showAction
        if @props.contact.get('isGuest')
          span className: 'role muted flex-static', lang.getText('quote-guest')
        else
          span className: 'role muted flex-static', lang.getText(role)
      @props.children

  renderAvatar: ->
    props =
      size: 'small'
      shape: 'round'
      className: 'flex-static'
    if @props.contact.get('avatarUrl')
      props.src = @props.contact.get('avatarUrl')
    else
      props.className = 'no-avatar'

    Avatar(props)

  renderBody: ->
    div className: 'body flex-horiz line flex-fill',
      UserAlias
        _teamId: @props._teamId
        _userId: @props.contact.get('_id')
        defaultName: @props.contact.get('name')
      if @isMe()
        span className: 'muted info flex-static', "(#{l('me')})"
      @renderRobotIcon()

  render: ->
    @renderContact()
