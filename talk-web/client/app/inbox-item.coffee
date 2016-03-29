cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'
msgDsl = require 'talk-msg-dsl'

query = require '../query'

colors = require '../util/colors'
lang = require '../locales/lang'
emojiUtil = require '../util/emoji'

notificationAction = require '../actions/notification'

Icon = React.createFactory require '../module/icon'
Avatar = React.createFactory require '../module/avatar'
RoomName = React.createFactory require '../module/room-name'
UserName = React.createFactory require '../module/user-name'
UnreadBadge = React.createFactory require '../module/unread-badge'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ i, div, span } = React.DOM
T = React.PropTypes

INBOX_COLOR =
  'dms': 'red'
  'file': 'purple'
  'link': 'green'
  'room': 'blue'
  'topic': 'yellow'

ICONS_MAP =
  'file': 'paperclip'
  'link': 'chain'
  'room': 'shape'
  'topic': 'idea'

TEXT_REGEXP = /\{\{__([\w-]+)\}\}/g

module.exports = React.createClass
  displayName: 'inbox-item'
  mixins: [ PureRenderMixin ]

  propTypes:
    isFake: T.bool
    isMute: T.bool
    isActive: T.bool
    isPinned: T.bool
    isSelected: T.bool
    isRemovable: T.bool
    isClearingUnread: T.bool
    onClick: T.func
    onRemove: T.func
    unreadNum: T.number
    notification: T.instanceOf(Immutable.Map).isRequired

  getDefaultProps: ->
    isFake: false
    isMute: false
    isActive: false
    isPinned: false
    isSelected: false
    isRemovable: false
    onClick: (->)
    onRemove: (->)

  handleClickOnComponent: (event) ->
    @props.onClick event, @props.notification

  handleClickOnButtonRemove: (event) ->
    return if not @props.isRemovable
    @props.onRemove event, @props.notification

  renderAvatar: (target, type) ->
    switch @props.notification.get('type')
      when 'dms'
        src = target.get 'avatarUrl'
      when 'room'
        iconName = ICONS_MAP[ type ]
      when 'story'
        iconName = ICONS_MAP[ target.get 'category' ]

    Avatar
      src: src, size: 'small', shape: 'round'
      className: 'white', backgroundColor: colors[ INBOX_COLOR[ type ]]
      if iconName
        Icon name: iconName, size: 12

  renderCap: ->
    div className: 'inbox-item-cap flex-horiz flex-vcenter',
      @renderTitle()
      @renderTags()

  renderInfo: ->
    div className: 'inbox-item-info flex-horiz flex-vcenter',
      @renderText()
      @renderUnread()

  renderTitle: ->
    target = @props.notification.get('target')
    div className: 'title text-overflow flex-fill',
      switch @props.notification.get('type')
        when 'dms'
          UserName
            _teamId: @props.notification.get '_teamId'
            _userId: target.get '_id'
            name: target.get 'name'
            isRobot: target.get 'isRobot'
            service: target.get 'service'
        when 'room'
          RoomName
            name: target.get 'topic'
        when 'story'
          target.get 'title'

  renderText: ->
    noty = @props.notification
    text = noty.get 'text'
    type = noty.get 'type'

    if text?.length > 0
      authorName = noty.get 'authorName'
      creatorName = noty.getIn [ 'creator', 'name' ]
      displayName = authorName or creatorName

      isMatched = text.match TEXT_REGEXP
      if isMatched
        text = text.replace TEXT_REGEXP, (raw, key) ->
          replacedText = lang.getText key
          "#{ displayName or '' } #{ replacedText or key }"

      if type isnt 'dms' and not isMatched
        if displayName
          displayName = "#{ displayName }:"
        text = "#{ displayName or '' } #{ text }"

      text = msgDsl.util.escapeHtml text
      text = emojiUtil.replace text

    div className: 'text text-overflow flex-fill', dangerouslySetInnerHTML: __html: text or '&nbsp;'

  renderUnread: ->
    return null if @props.isFake
    return null if not @props.unreadNum
    return null if @props.isClearingUnread

    span className: 'unread flex-static',
      if @props.isMute
        UnreadBadge
          size: 8
          round: true
          showNumber: false
          number: @props.unreadNum
      else
        UnreadBadge
          size: 16
          oval: true
          number: @props.unreadNum
          showNumber: true

  renderTags: ->
    return null if @props.isFake
    showRemove = not (@props.isPinned or @props.unreadNum > 0 or not @props.isRemovable)
    cxTags = cx 'tags', 'flex-static', 'flex-horiz', 'flex-vcenter', 'show-remove': showRemove
    div className: cxTags,
      if @props.isPinned
        Icon size: 14, name: 'pin', className: 'pin'
      if @props.isMute
        Icon size: 14, name: 'mute', className: 'mute'
      if showRemove
        Icon size: 16, name: 'remove', className: 'remove', onClick: @handleClickOnButtonRemove

  render: ->
    noty = @props.notification
    type = noty.get 'type'
    if type is 'story'
      type = noty.getIn [ 'target', 'category' ]
    target = noty.get 'target'

    className = cx 'inbox-item',
      'active': @props.isActive
      'pinned': @props.isPinned
      'selected': @props.isSelected
    # Prevent error render method,
    # caused by empty target or null type.
    return null if not (type? and target?)

    div className: className, onClick: @handleClickOnComponent,
      @renderAvatar target, type
      div className: 'body',
        @renderCap()
        @renderInfo()
