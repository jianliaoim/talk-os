React   = require 'react'
Immutable = require 'immutable'
classnames = require 'classnames'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
mixinSubscribe = require '../mixin/subscribe'

deviceActions = require '../actions/device'
routerHandlers = require '../handlers/router'

LightModal   = React.createFactory require '../module/light-modal'
TimeDivider = React.createFactory require '../module/time-divider'

MessageRich   = React.createFactory require '../app/message-rich'
MessageSlim   = React.createFactory require '../app/message-slim'
MessageSystem = React.createFactory require '../app/message-system'
UnreadDivider = React.createFactory require '../app/unread-divider'
FileQueueChannel = React.createFactory require './file-queue-channel'

time   = require '../util/time'
orders = require '../util/orders'
util = require '../util/util'
analytics = require '../util/analytics'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-timeline'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _toId: T.string
    _roomId: T.string
    _teamId: T.string.isRequired
    _storyId: T.string
    unread: T.number.isRequired
    preview: T.bool
    messages: T.instanceOf(Immutable.List)
    selectedId: T.string
    readMessageId: T.string
    isMessageHighlight: T.bool

  getDefaultProps: ->
    preview: false

  getInitialState: ->
    hasUnread = @props.unread? and @props.unread > 0
    # return an object
    displayMode: @getDisplayMode()
    cacheReadMessageId: if hasUnread then @props.readMessageId else null
    contacts: @getContacts()
    showFileQueue: false
    cursorAttachment: null
    editMessageId: null

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        displayMode: @getDisplayMode()
        contacts: @getContacts()
        editMessageId: @getMessageEditId()

  getDisplayMode: ->
    prefs = query.prefs(recorder.getState())
    prefs?.get('displayMode') or 'default'

  getContacts: ->
    query.contactsBy(recorder.getState(), @props._teamId) or Immutable.List()

  getMessageEditId: ->
    query.getEditMessageId(recorder.getState())

  # custom methods

  getCreatorRole: (creator) ->
    _userId = query.userId(recorder.getState())

    unless creator? then return 'unknown'
    if creator.get('isRobot') then return 'robot'
    if creator.get('_id') is _userId then return 'me'
    count = @state.contacts
    .filter (contact) -> contact.get('_id') is creator.get('_id')
    .length > 0
    if count > 0 then 'member' else 'other'

  isPermitted: ->
    _userId = query.userId(recorder.getState())
    contact = @state.contacts.find (contact) ->
      contact.get('_id') is _userId
    if contact? then contact.get('role') in ['admin', 'owner'] else false

  # event handlers

  onFileClick: (attachment) ->
    @setState showFileQueue: true, cursorAttachment: attachment
    deviceActions.viewAttachment attachment.get('_id')
    file = attachment.get('data')
    if file.get('fileCategory') is 'image' and file.get('thumbnailUrl')
      analytics.viewImage()
    else
      analytics.viewFile()

  onFileQueueHide: ->
    @setState showFileQueue: false
    deviceActions.viewAttachment null

  onTagClick: (_tagId) ->
    routerHandlers.tags @props._teamId,
      _toId: @props._toId
      _tagId: _tagId
      _roomId: @props._roomId
      _storyId: @props._storyId

  # render methods

  renderFileQueue: ->
    messages = @props.messages.sort orders.imMsgByCreatedAtWithId
    LightModal
      name: 'file-queue'
      show: @state.showFileQueue
      onCloseClick: @onFileQueueHide
      if @state.showFileQueue then FileQueueChannel
        onClose: @onFileQueueHide
        messages: messages
        attachment: @state.cursorAttachment
        _teamId: @props._teamId
        _toId: @props._toId
        _roomId: @props._roomId
        _storyId: @props._storyId

  renderTimeline: ->
    timeline = []
    lastTime = null
    lastUser = null
    lastMessage = null
    forAdmin = @isPermitted()

    util.combineMessages(@props.messages).forEach (message) =>
      # missing creator in some messages
      thisUser = message.get('creator')?.get('_id') or message.get('authorName') or null
      thisTime = message.get('createdAt')

      notSameDay = (lastTime? and (time.notSameDay lastTime, thisTime)) or (not lastTime)
      isDuplicated = thisUser is lastUser and \
                      message.get('attachments').size is 0 and \
                      not notSameDay and \
                      time.within1Minute(lastTime, thisTime)

      props =
        key: message.get('_id')
        message: message
        selected: message.get('_id') is @props.selectedId
        showActions: true
        isDuplicated: isDuplicated
        onFileClick: @onFileClick
        isUnread: message.get('_id') > @state.cacheReadMessageId
        showTags: true
        preview: @props.preview
        onTagClick: @onTagClick
        isEditMode: @state.editMessageId is message.get('_id')

      if @state.cacheReadMessageId? and @state.cacheReadMessageId is lastMessage
        timeline.push UnreadDivider key: 'unread-divider', onAllRead: @onAllRead

      if @state.displayMode is 'default'
        if notSameDay
          timeline.push TimeDivider
            data: thisTime
            key: thisTime

      if message.get('isSystem')
        type = if @state.displayMode is 'default' then 'rich' else 'slim'
        timeline.push MessageSystem key: message.get('_id'), message: message, type: type
      else
        if @state.displayMode is 'slim'
          timeline.push (MessageSlim props)
        else
          timeline.push (MessageRich props)

      lastTime = thisTime
      lastUser = thisUser
      # to provide a divide line after system message
      if message.get('isSystem') then lastUser = null
      lastMessage = message.get('_id')

    timeline

  render: ->
    className = classnames 'message-timeline',
      'is-message-highlight': @props.isMessageHighlight

    div className: className,
      @renderTimeline()
      @renderFileQueue()
