React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'
mixinMessageHandler = require '../mixin/message-handler'

routerHandlers = require '../handlers/router'

ContactName = React.createFactory require './contact-name'
MsgFile     = React.createFactory require './msg-file'
PostCard    = React.createFactory require './post-card'
SnippetCard = React.createFactory require './snippet-card'

RelativeTime = React.createFactory require '../module/relative-time'

div = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'msg-result'
  mixins: [mixinMessageHandler, PureRenderMixin]

  propTypes:
    _teamId:     T.string.isRequired
    message:     T.instanceOf(Immutable.Map)
    attachment:  T.instanceOf(Immutable.Map)
    type:        T.oneOf ['file', 'post', 'link', 'snippet']
    onFileClick: T.func

  getDefaultProps: ->
    onFileClick: ->

  getData: ->
    @props.attachment.get 'data'

  onPostClick: ->
    @onPostViewerShow()

  onLinkClick: (event) ->
    event.stopPropagation()
    @onLinkViewerShow()

  onSnippetClick: ->
    @onSnippetViewerShow()

  onIconClick: (event) ->
    event.stopPropagation()
    window.open @getData().get('redirectUrl')

  onMessageClick: (message) ->
    _teamId = message.get('_teamId')
    _toId = message.get('_toId')
    _roomId = message.get('_roomId')
    _id = message.get('_id')
    _userId = query.userId(recorder.getState())
    if _roomId?
      routerHandlers.room _teamId, _roomId, {search: _id}
    else # count on _toId
      if _toId is _userId
        _toId = message.get('_creatorId')
      routerHandlers.chat _teamId, _toId, {search: _id}

  renderFile: ->
    attachment = @props.attachment
    MsgFile key: attachment.get('_id'), attachment: attachment, onClick: @props.onFileClick

  renderPost: ->
    return if @props.attachment.get('category') isnt 'rtf'
    PostCard text: @getData().get('text'), onClick: @onPostClick

  renderLink: ->
    div className: 'link-box', onClick: @onLinkClick,
      div className: 'title',
        span className: 'title-text', @getData().get('title')
        if @getData().get('redirectUrl')?
          span className: 'ti ti-redirect', onClick: @onIconClick
      if @getData().get('text')
        div className: 'text',
          @getData().get('text')

  renderSnippet: ->
    SnippetCard
      mode: @getData().get('codeType')
      text: @getData().get('text')
      title: @getData().get('title')
      onClick: @onSnippetClick

  render: ->
    message = @props.message
    onClick = => @onMessageClick message

    div className: "msg-result is-#{ @props.type }", onClick: onClick,
      div className: 'content',
        switch @props.type
          when 'file'    then @renderFile()
          when 'post'    then @renderPost()
          when 'link'    then @renderLink()
          when 'snippet' then @renderSnippet()
      div className: 'creator',
        ContactName contact: message.get('creator'), _teamId: @props._teamId
      div className: 'channel',
        if message.get('room')?
          message.getIn(['room', 'topic'])
        else
          lang.getText('conversation')
      div className: 'time',
        RelativeTime data: message.get('createdAt')

      @renderLinkViewer()
      @renderPostViewer()
      @renderSnippetViewer()
