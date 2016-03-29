cx = require 'classnames'
React = require 'react'
ReactDOM = require 'react-dom'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

prefsActions = require '../actions/prefs'
notifyActions = require '../actions/notify'
accountActions = require '../actions/account'
settingsActions = require '../actions/settings'

lang = require '../locales/lang'
handlers = require '../handlers'

analytics = require '../util/analytics'

mixinModal = require '../mixin/modal'
mixinPopouts = require '../mixin/popouts'
mixinChannelInfo = require '../mixin/channel-info'

Permission = require '../module/permission'

ChannelMore = React.createFactory require './channel-more'
ChannelMember = React.createFactory require './channel-member'

Icon = React.createFactory require '../module/icon'

LiteSwitcher = React.createFactory require('react-lite-misc').Switcher
LitePopoverBeta = React.createFactory require '../module/popover-beta'
Tooltip = React.createFactory require '../module/tooltip'

ReactCSSTransitionGroup = React.createFactory require 'react-addons-css-transition-group'

{ a, div, noscript } = React.DOM
T = React.PropTypes

POPOUTS_TYPE = [ 'member', 'more' ]

module.exports = React.createClass
  displayName: 'channel-action'
  mixins: [ mixinChannelInfo, mixinModal, mixinPopouts , PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    _channelId: T.string.isRequired
    _channelType: T.string.isRequired
    prefs: T.instanceOf(Immutable.Map)
    channel: T.instanceOf(Immutable.Map).isRequired
    members: T.instanceOf(Immutable.List)
    contacts: T.instanceOf(Immutable.List)
    isEditable: T.bool.isRequired

  componentDidMount: ->
    @_moreEl = ReactDOM.findDOMNode(@refs.more)
    @_memberEl = @refs.member

  componentWillUnmount: ->
    @_moreEl = null
    @_membersEl = null

  onClickMember: (event) ->
    event.stopPropagation()
    @onTogglePopouts @_memberEl, POPOUTS_TYPE[0]

  onClickMore: (event) ->
    event.stopPropagation()
    @onTogglePopouts @_moreEl, POPOUTS_TYPE[1]

  onOpenDrawerStory: (event) ->
    event.stopPropagation()
    settingsActions.openDrawer 'story'

  onOpenDrawerCollection: (event) ->
    event.stopPropagation()
    handlers.collection.query(@props._teamId, @props._channelId, @props._channelType)
    settingsActions.openDrawer 'collection'

  onInteClick: ->
    accountActions.fetch()
    if @props._channelType is 'room'
      handlers.router.integrations(@props._teamId, @props._channelId)
    else
      handlers.router.integrations()
    analytics.openIntegrationFromRoom(@props._teamId)

  onUpdateTalkAIReply: ->
    needReply = @props.prefs
    .getIn [ 'customOptions', 'needTalkAIReply' ]

    customOptions = @props.prefs
    .getIn [ 'customOptions' ]
    .set 'needTalkAIReply', not needReply

    prefsActions
    .prefsUpdate customOptions: customOptions.toJS()
    , ->
      notifyActions.success lang.getText if not needReply then 'open-res-successed' else 'close-res-successed'
    , ->
      notifyActions.error lang.getText 'error'

  renderPopouts: ->
    title = lang.getText @state.popoutsType
    if @state.popoutsType is POPOUTS_TYPE[0]
      title = "#{ title } (#{ @props.channel.get('_memberIds').size })"

    LitePopoverBeta
      name: 'channel-action'
      show: @state.showPopouts
      title: title
      baseArea: @getPopoutsBaseArea()
      showClose: true
      onPopoverClose: @onClosePopouts
      switch @state.popoutsType
        when POPOUTS_TYPE[0]
          ChannelMember
            _teamId: @props._teamId
            _channelType: @props._channelType
            channel: @props.channel
        when POPOUTS_TYPE[1]
          ChannelMore
            _teamId: @props._teamId
            _channelId: @props._channelId
            _channelType: @props._channelType
            channel: @props.channel
            onClose: @onClosePopouts
            onInteClick: @onInteClick
        else noscript()

  renderButton: ->

    buttonInfo = =>
      return noscript() if not @isChannel 'story'

      Tooltip template: lang.getText('details'),
        a className: 'action', onClick: @onOpenDrawerStory,
          Icon size: 16, name: 'open-drawer'

    buttonCollection = =>
      Tooltip template: lang.getText('automatic-collection'),
        a className: 'action', onClick: @onOpenDrawerCollection,
          Icon size: 16, type: 'icon', name: 'collection'

    buttonShortcut = =>
      return noscript() if not @isChannel 'story'

      name =
        switch @props.channel.getIn [ 'category' ]
          when 'file' then 'arrow-down'

      return noscript() if not name?

      onClick = (e) => window.open @props.channel.getIn [ 'data', 'downloadUrl' ]
      Tooltip template: lang.getText('download'),
        a className: 'action', title: 'Download', onClick: onClick,
          Icon size: 16, name: name

    buttonMember = =>
      return noscript() if @isChannel 'chat'

      Tooltip template: lang.getText('member'),
        a ref: 'member', className: 'action', onClick: @onClickMember,
          Icon size: 16, name: 'users'

    buttonMore = =>
      return noscript() if (@isChannel 'chat') or @isQuitted()

      Tooltip ref: 'more', template: lang.getText('setting'),
        MoreClassPermission
          _teamId: @props._teamId
          _creatorId: @props.channel.get '_creatorId'
          onClick: @onClickMore

    buttonTalkAI = =>
      return noscript() if not @isTalkAI()

      div className: 'flex-horiz flex-vcenter row small',
        LiteSwitcher
          checked: @props.prefs.getIn [ 'customOptions', 'needTalkAIReply' ]
          onClick: @onUpdateTalkAIReply
        lang.getText 'intelligent-response'

    div className: 'flex-horiz row large',
      buttonInfo()
      buttonCollection()
      buttonShortcut()
      buttonMember()
      buttonMore()
      buttonTalkAI()

  render: ->
    div className: 'channel-action flex-horiz flex-static',
      @renderButton()
      @renderPopouts()
      # render intergration page.
      ReactCSSTransitionGroup
        transitionEnterTimeout: 200
        transitionLeaveTimeout: 200
        transitionName: 'fade'
        if @state.showInte
          @renderIntePage @props._teamId, @props._channelId

MoreClass = React.createClass
  displayName: 'permission-more'

  mixins: [ PureRenderMixin]

  propTypes:
    onClick: T.func.isRequired

  onClick: (event) ->
    @props.onClick event

  render: ->
    a className: 'action', onClick: @onClick,
      Icon size: 18, name: 'cog'

MoreClassPermission = React.createFactory Permission.create MoreClass, Permission.member
