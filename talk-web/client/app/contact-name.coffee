cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

lang = require '../locales/lang'

detect = require '../util/detect'

UserAlias = React.createFactory require './user-alias'

Icon = React.createFactory require '../module/icon'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'contact-name'
  mixins: [PureRenderMixin]

  propTypes:
    active: T.bool
    hover: T.bool
    isMe: T.bool
    isQuit: T.bool
    showAvatar: T.bool
    showEmail: T.bool
    showUnread: T.bool
    onClick: T.func
    onMouseEnter: T.func
    _teamId: T.string.isRequired
    contact: T.instanceOf(Immutable.Map)

  getDefaultProps: ->
    active: false
    hover: false
    isMe: false
    showAvatar: true
    showEmail: false
    showUnread: false
    contact: Immutable.Map()

  onClick: (event) ->
    # event.stopPropagation()
    @props.onClick? @props.contact.get('_id'), event

  onMouseEnter: ->
    @props.onMouseEnter?()

  renderName: ->
    if @props.contact.get('_id') is 'all'
      span className: 'name', lang.getText 'all-members'
    else
      UserAlias _userId: @props.contact.get('_id'), _teamId: @props._teamId, defaultName: @props.contact.get('name')

  renderRobotIcon: ->
    if detect.isRobot(@props.contact)
      span className: 'icon icon-talkai flex-static'

  renderIsQuit: ->
    if @props.isQuit
      span className: 'left', "(#{lang.getText('contact-quitted')})"

  renderAvatar: ->
    ## hack way, cause cannot find the problem locally.
    return if not @props.contact.get('avatarUrl')?
    if @props.showAvatar
      avatarStyle = if @props.contact.get('avatarUrl').length then { backgroundImage: "url(#{ @props.contact.get('avatarUrl') })" } else {}
      span className: 'is-leading avatar img-circle img-24', style: avatarStyle

  renderStates: ->
    isGuest = @props.contact.get('isGuest')
    isMe = @props.isMe
    if isGuest or isMe
      div className: 'states',
        if isGuest
          span className: 'guest', lang.getText('quote-guest')
        if isMe
          span className: 'muted',
            " (#{lang.getText('me')})"

  renderEmail: ->
    # special in user search
    if @props.showEmail
      span className: 'email muted', @props.contact.get('email')

  renderUnread: ->
    if @props.showUnread and (@props.contact.get('unread') > 0)
      span className: 'icon-unread', @props.contact.get('unread')

  renderMention: ->
    # special in mention
    @props.children

  renderSelect: ->
    if @props.active
      Icon name: 'tick', size: 14, type: 'icon', className: 'flex-static'

  render: ->
    className = cx 'banner', 'contact-name', 'item', 'line',
      'hover': @props.hover
      'is-quit': @props.isQuit

    div onClick: @onClick, onMouseEnter: @onMouseEnter, className: className,
      @renderAvatar()
      @renderName()
      @renderRobotIcon()
      @renderIsQuit()
      @renderStates()
      @renderEmail()
      @renderMention()
      @renderUnread()
      @renderSelect()
