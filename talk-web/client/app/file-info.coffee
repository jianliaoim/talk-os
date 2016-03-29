React = require 'react'
cx = require 'classnames'
filesize = require 'filesize'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
uploadUtil  = require '../util/upload'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
query = require '../query'
config = require '../config'
handlers = require '../handlers'

messageActions = require '../actions/message'
favoriteActions = require '../actions/favorite'

RelativeTime = React.createFactory require '../module/relative-time'

MessageToolbar = React.createFactory require './message-toolbar'
UserAlias =  React.createFactory require './user-alias'
TopicCorrection =  React.createFactory require './topic-correction'

a = React.createFactory 'a'
div = React.createFactory 'div'
span = React.createFactory 'span'

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-info'
  mixins: [PureRenderMixin]

  propTypes:
    message: T.instanceOf(Immutable.Map)
    attachment: T.instanceOf(Immutable.Map)
    isFavorite: T.bool

  getDefaultProps: ->
    isFavorite: false

  getInitialState: ->
    isMe: false

  isMe: (id) ->
    id is query.userId(recorder.getState())

  getFile: ->
    @props.message.getIn(['attachments', @getAttachmentIndex(), 'data'])

  getAttachmentIndex: ->
    index = @props.message.get('attachments').findIndex (cursor) =>
      cursor.get('_id') is @props.attachment.get('_id')
    index or 0

  onUploaderComplete: ({fileData}) ->
    newMessage = @props.message.updateIn ['attachments', @getAttachmentIndex(), 'data'], (oldData) ->
      oldData.merge fileData
    messageActions.messageUpdate newMessage.get('_id'), newMessage.toJS()

  onFileClick: (event) ->
    uploadUtil.handleClick
      onSuccess: @onUploaderComplete
      onError: handlers.fileError
      metaData: handlers.file.getNewMessageInfo()

  # renderers

  renderSender: ->
    UserAlias
      _teamId: @props.message.get('_teamId')
      _userId: @props.message.get('_creatorId')
      defaultName: @props.message.getIn(['creator', 'name'])
      replaceMe: true

  renderReceiver: ->
    switch @props.message.get('type')
      when 'dms'
        UserAlias
          _teamId: @props.message.get('_teamId')
          _userId: @props.message.get('_toId')
          defaultName: @props.message.getIn(['to', 'name'])
          replaceMe: true
      when 'room'
        TopicCorrection
          topic: @props.message.get('room')
      when 'story'
        @props.message.getIn(['story', 'title'])

  renderContent: ->
    div className: 'content',
      @renderSender()
      span className: 'arrow-right'
      @renderReceiver()
      l('comma')
      RelativeTime data: @props.message.get('createdAt')

  renderToolbar: ->
    file = @getFile()
    _userId = query.userId(recorder.getState())
    byMe = @props.message.get('_creatorId') is _userId
    div className: 'toolbar',
      if byMe and not @props.isFavorite
        span className: 'icon icon-upload', onClick: @onFileClick
      if @props.isFavorite
        a href: file.get('downloadUrl'),
          span className: 'icon icon-download'
      else
        MessageToolbar
          message: @props.message
          attachmentIndex: @getAttachmentIndex()
          hideMenu: true
          showInline: not @props.isFavorite
          showTrash: byMe

  renderTitle: ->
    file = @getFile()
    div className: 'title',
      file.get('fileName')
      span className: 'muted', " (#{filesize file.get('fileSize'), unix: true})"

  render: ->
    div className: 'file-info',
      div className: 'info',
        @renderTitle()
        @renderToolbar()
      @renderContent()
