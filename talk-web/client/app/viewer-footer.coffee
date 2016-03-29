React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ContactName    = React.createFactory require './contact-name'
MessageToolbar = React.createFactory require './message-toolbar'
UserAlias =  React.createFactory require './user-alias'
StoryName = React.createFactory require './story-name'
RelativeTime  = React.createFactory require '../module/relative-time'
TopicCorrection = React.createFactory require './topic-correction'

messageActions = require '../actions/message'
favoriteActions = require '../actions/favorite'

query = require '../query'
lang = require '../locales/lang'

{div, span} = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'viewer-footer'
  mixins: [PureRenderMixin]

  propTypes:
    isFavorite: T.bool
    canEdit: T.bool
    message: T.instanceOf(Immutable.Map)

  getDefaultProps: ->
    canEdit: true
    isFavorite:  false

  renderChannel: ->
    _userId = query.userId(recorder.getState())
    switch @props.message.get('type')
      when 'room'
        span null,
          UserAlias
            _teamId: @props.message.get('_teamId')
            _userId: @props.message.get('_creatorId')
            defaultName: @props.message.getIn(['creator', 'name'])
            replaceMe: true
          span className: 'arrow-right', null
          TopicCorrection
            topic: @props.message.get('room')
      when 'dms'
        ContactName contact: @props.message.get('creator'), _teamId: @props.message.get('_teamId')
      when 'story'
        story = @props.message.get('story')
        span null,
          UserAlias
            _teamId: @props.message.get('_teamId')
            _userId: @props.message.get('_creatorId')
            defaultName: @props.message.getIn(['creator', 'name'])
            replaceMe: true
          span className: 'arrow-right', null
          StoryName title: story.get('title'), category: story.get('category'), showIcon: false

  render: ->
    message = @props.message

    div className: 'viewer-footer',
      div className: 'info',
        @renderChannel()
        lang.getText('comma')
        RelativeTime data: message.get('createdAt'), edited: message.get('updatedAt')
      unless @props.isFavorite
        MessageToolbar message: message, hideMenu: true, showInline: @props.canEdit
