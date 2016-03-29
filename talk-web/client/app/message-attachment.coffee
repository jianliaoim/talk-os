React = require 'react'
Immutable = require 'immutable'
cx = require 'classnames'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
mixinMessageHandler = require '../mixin/message-handler'
mixinMessageContent = require '../mixin/message-content'

UserAlias = React.createFactory require './user-alias'
RelativeTime = React.createFactory require '../module/relative-time'

div    = React.createFactory 'div'
span   = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-attachment'
  mixins: [mixinMessageHandler, mixinMessageContent, PureRenderMixin]

  propTypes:
    message: T.instanceOf(Immutable.Map)

  renderMessageAuthor: ->
    return if not @props.message.has('creator')

    style =
      if @props.message.has('authorAvatarUrl')
        backgroundImage: "url(#{ @props.message.get('authorAvatarUrl') })"
      else
        backgroundImage: "url(#{ @props.message.getIn(['creator', 'avatarUrl']) })"

    div
      ref: 'author'
      className: 'author flex-static'
      span className: 'avatar flex-static img-circle background-cover', style: style, onClick: @onAuthorClick

  renderMessageContainer: ->
    if @props.message.get('body')?.length
      className = cx 'body', 'text'
    else
      className = 'body'
    div className: 'container',
      div className: className,
        @renderMessageTitle()
        @renderMessageContent()

  renderMessageTitle: ->
    div className: 'header flex-horiz line',
      span className: 'bold', onClick: @onAuthorClick,
        UserAlias _teamId: @props.message.get('_teamId'), _userId: @props.message.get('_creatorId'), defaultName: @getAuthorName()
      RelativeTime data: @props.message.get('createdAt'), edited: @props.message.get('updatedAt')

  renderMessageContent: ->
    return if not @props.message.get('body')?.length
    @renderContent()

  renderMessage: ->
    return div {} if not @props.message?
    _userId = query.userId(recorder.getState())

    classMessage = cx 'message-rich', 'flex-horiz',
      'is-duplicated': @props.isDuplicated
      'be-mine': @props.message.getIn(['creator', '_id']) is _userId
      'is-robot': @props.message.getIn(['creator', 'isRobot'])
      'is-selected': @props.selected
      'is-local': @props.message.get('isLocal')

    div className: classMessage, onClick: @onClick,
      @renderMessageAuthor()
      @renderMessageContainer()

  render: ->
    @renderMessage()
