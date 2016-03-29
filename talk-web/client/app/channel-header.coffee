cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'

query = require '../query'

notifyActions = require '../actions/notify'
notificationAction = require '../actions/notification'

lang = require '../locales/lang'

Icon = React.createFactory require '../module/icon'
ChannelInfo = React.createFactory require './channel-info'
ChannelAction = React.createFactory require './channel-action'

Tooltip = React.createFactory require '../module/tooltip'

{ a, div, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'channel-header'

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    _channelId: T.string
    _channelType: T.string.isRequired
    prefs: T.instanceOf(Immutable.Map)
    channel: T.instanceOf(Immutable.Map).isRequired
    members: T.instanceOf(Immutable.List)
    contacts: T.instanceOf(Immutable.List)
    notification: T.instanceOf(Immutable.Map).isRequired

  isPinned: ->
    @props.notification.get('isPinned')

  isMute: ->
    @props.notification.get('isMute')

  isPreview: ->
    isQuit = @props.channel.has('isQuit') and @props.channel.get('isQuit')
    isArchived = @props.channel.get('isArchived')
    isQuit or isArchived

  getPermission: ->
    (@props.channel.get('_creatorId') is @props._userId)

  onPinClick: (event) ->
    event.stopPropagation()

    data =
      isPinned: not @isPinned()
    notificationAction.update @props.notification.get('_id'), data

  onMuteClick: (event) ->
    event.stopPropagation()

    data =
      isMute: not @isMute()

    notificationAction.update @props.notification.get('_id'), data

  renderAction: ->
    return noscript() if @isPreview()
    ChannelAction
      _teamId: @props._teamId
      _userId: @props._userId
      _channelId: @props._channelId
      _channelType: @props._channelType
      prefs: @props.prefs
      channel: @props.channel
      members: @props.members
      contacts: @props.contacts
      isEditable: @getPermission()

  renderInfo: ->
    div className: 'flex-horiz flex-space flex-vcenter',
      ChannelInfo
        _teamId: @props._teamId
        _channelType: @props._channelType
        channel: @props.channel
      @renderInstant()

  renderMuteIcon: ->
    isMute = @isMute()
    template = if isMute then lang.getText('enable-topic-notifications') else lang.getText('disable-topic-notifications')
    Tooltip template: template,
      a ref: 'mute', className: cx('action', 'is-mute': isMute), onClick: @onMuteClick,
        Icon name: 'mute', size: 18

  renderPinIcon: ->
    isPinned = @isPinned()
    template = if isPinned then lang.getText('unpin') else lang.getText('pin')
    Tooltip template: template,
      a className: cx('action', 'is-pin': isPinned), onClick: @onPinClick,
        Icon name: 'pin', size: 16

  renderInstant: ->
    return noscript() if @isPreview()
    div className: 'channel-instant flex-horiz row',
      if @props.channel.get 'isPrivate'
        Tooltip template: lang.getText('private-topic'),
          Icon type: 'icon', name: 'lock',
      if @props.channel.get('guestToken')?
        Tooltip template: lang.getText('guest-mode'),
          Icon type: 'icon', name: 'eye', size: 18
      @renderMuteIcon()
      @renderPinIcon()

  render: ->
    div className: 'channel-header flex-between flex-horiz flex-static flex-vcenter',
      @renderInfo()
      @renderAction()
