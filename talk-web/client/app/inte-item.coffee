React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

div  = React.createFactory 'div'
span = React.createFactory 'span'
a    = React.createFactory 'a'
{code} = React.DOM

Icon  = React.createFactory require '../module/icon'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'inte-item'
  mixins: [PureRenderMixin]

  propTypes:
    data:     T.instanceOf(Immutable.Map)
    onClick:  T.func.isRequired
    showRobot: T.bool

  getDefaultProps: ->
    showRobot: false

  onClick: ->
    @props.onClick @props.data

  renderNotifications: (it) ->
    notifications = [
      if it.mention?        then span key: 'mention',         l('mention')
      if it.repost?         then span key: 'repost',          l('repost')
      if it.comment?        then span key: 'comment',         l('comment')
      if it.message?        then span key: 'message',         l('on-new-message')
      # gitlab
      if it.push?           then span key: 'push',            l('push')
      if it.issues?         then span key: 'issues',          l('issues')
      if it.merge_request?  then span key: 'merge_request',   l('merge')
      # github
      if it.commit_comment? then span key: 'commit_comment',  l('info-commit_comment')
      if it.create?         then span key: 'create',          l('info-create')
      if it.delete?         then span key: 'delete',          l('info-delete')
      if it.fork?           then span key: 'fork',            l('info-fork')
      if it.issue_comment?  then span key: 'issue_comment',   l('info-issue_comment')
      if it.pull_request?   then span key: 'pull_request',    l('info-pull_request')
      if it.pull_request_review_comment?
        span key: 'pull_request_review_comment',
          l('info-pull_request_review_comment')
    ].filter (x) -> x?
    div className: 'actions line muted', notifications[...3]

  render: ->
    url = @props.data.get('webhookUrl')
    iconStyle = {}
    if @props.data.get('iconUrl')?
      iconStyle.backgroundImage = "url(#{@props.data.get('iconUrl')})"

    div className: "inte-item is-#{@props.data.get('category')}",
      div className: 'icon-col',
        div className: 'icon category', style: iconStyle
        if @props.data.get('errorInfo')?
          span className: 'ti ti-alert-circle-solid warning'
      div className: 'service-col',
        div className: 'title line',
          div className: 'title-text',
            @props.data.get('title') or @props.data.get('showname') or @props.data.get('category')
          if @props.showRobot
            div className: 'robot-tip',
              span className: 'robot-guide', lang.getText('robot-id'), ":"
              code className: 'robot-code', @props.data.get('_robotId')
          if @props.data.get('isNew')
            span className: 'label label-default is-new', l('new-added')
        if @props.data.get('errorInfo')?
          span className: 'errorinfo',
            lang.getText('errored-integration')
            @props.data.get('errorInfo')
        else if @props.data.get('description')
          div className: 'description muted', @props.data.get('description')
        else if @props.data.get('notifications')?
          @renderNotifications @props.data.get('notifications')
        else
          div className: 'description muted', l('no-description')

      div className: 'action-col',
        if @props.data.get('canEdit')
          div className: 'edit button is-primary ', onClick: @onClick,
            Icon name: 'edit', size: 16
            span className: 'text', l('edit')
