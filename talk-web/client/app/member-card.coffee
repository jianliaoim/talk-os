
React   = require 'react'
cx =require 'classnames'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

config = require '../config'
query = require '../query'
lang  = require '../locales/lang'

Icon = React.createFactory require '../module/icon'
UserAlias = React.createFactory require './user-alias'

mixinSubscribe = require '../mixin/subscribe'

detect  = require '../util/detect'
analytics  = require '../util/analytics'

messageActions = require '../actions/message'
routerHandlers = require '../handlers/router'

{ div, span } = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'member-card'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId:       T.string.isRequired
    _contactId:    T.string
    showEntrance:   T.bool
    member: T.instanceOf(Immutable.Map)

  getDefaultProps: ->
    showEntrance: true
    member: Immutable.Map()

  getInitialState: ->
    text: ''
    prefs: @getPrefs()
    contact: @getContact()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        prefs: @getPrefs()
        contact: @getContact()

  isReachable: ->
    not @contactNotAvailable() and @props.showEntrance

  getPrefs: ->
    _contactId = @props._contactId or @props.member.get('_id')
    query.contactPrefsBy(recorder.getState(), @props._teamId, _contactId)

  getContact: ->
    query.requestContactsByOne(recorder.getState(), @props._teamId, @props._contactId) or @props.member

  contactNotAvailable: ->
    isRobotOrInte = @state.contact.get('isRobot')
    isGuest = @state.contact.get('isGuest')

    isRobotOrInte or isGuest

  onClick: ->
    analytics.enterChatFromRoom()
    routerHandlers.chat @props._teamId, @state.contact.get('_id')

  renderEntrance: ->
    return null unless @isReachable()
    span className: 'entrance flex-horiz flex-vcenter', onClick: @onClick,
      Icon size: 18, name: 'private-chat'
      lang.getText('member-card-entrance')

  renderName: ->
    div className: 'profile-name flex-horiz flex-vcenter',
      UserAlias
        _teamId: @props._teamId
        _userId: @state.contact.get('_id')
        defaultName: @state.contact.get('name')
      if not detect.isTalkai(@state.contact) and @state.contact.get('isRobot')
        Icon name: 'bot', className: 'muted flex-static'
      if @state.contact.get('isGuest')
        span className: 'muted flex-static', lang.getText('quote-guest')
      if @state.contact.get('isQuit')
        span className: 'muted flex-static', lang.getText('member-card-quit-hint')

  renderContacts: ->
    div className: 'contacts',
      if @state.contact.get('email')?
        div className: 'email short muted', @state.contact.get('email')
      else
        span className: 'no-email', lang.getText('no-email')
      if (not @state.prefs?.get('hideMobile')) and @state.contact.get('mobile')?
        div className: 'phone muted', @state.contact.get('mobile')

  render: ->
    avatarStyle =
      backgroundImage: "url('#{@state.contact.get('avatarUrl')}')"

    div className: 'member-card',
      div className: 'avatar', style: avatarStyle
      div className: 'profile text-overflow flex-vert',
        @renderName()
        @renderContacts()
        if not config.isGuest
          @renderEntrance()
