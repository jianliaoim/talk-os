
React = require 'react'
lang = require '../locales/lang'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'
detect  = require '../util/detect'

UserAlias = React.createFactory require './user-alias'

div    = React.createFactory 'div'
span   = React.createFactory 'span'
br    = React.createFactory 'br'
em = React.createFactory 'em'
strong = React.createFactory 'strong'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'member-item'
  mixins: [PureRenderMixin]

  propTypes:
    # this component expects children
    member: T.instanceOf(Immutable.Map)
    user: T.instanceOf(Immutable.Map)
    _teamId: T.string.isRequired
    isTopicCreator: T.bool

  getName: ->
    if @props.member.get('_id') is @props.user.get('_id')
    then "(#{lang.getText('me')})"

  renderRobotIcon: ->
    contact = query.requestContactsByOne(recorder.getState(), @props._teamId, @props.member.get('_id'))
    if contact? and not detect.isTalkai(contact) and (contact? and contact.get('isRobot'))
      span className: 'ti ti-bot'

  render: ->
    if @props.isTopicCreator
      role = 'topic-owner'
    else if @props.member.get 'isInvite'
      role = 'not-actived'
    else
      role = @props.member.get('role') or 'member'

    style =
      if not @props.member.get 'isInvite'
        backgroundImage: "url('#{@props.member.get('avatarUrl')}')"
      else {}

    div className: 'member-item line',
      div className: 'img-36 avatar img-circle member-avatar', style: style
      div className: 'info',
        div className: 'bold',
          UserAlias _userId: @props.member.get('_id'), _teamId: @props._teamId, defaultName: @props.member.get('name')
          @getName()
          @renderRobotIcon()
        div className: 'description',
          lang.getText(role)
      @props.children
