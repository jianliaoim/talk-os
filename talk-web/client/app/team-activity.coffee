
React = require 'react'
urlParse = require 'url-parse'
Immutable = require 'immutable'
classnames = require 'classnames'

lang = require '../locales/lang'
detect = require '../util/detect'
actions = require '../actions/index'
handlers = require '../handlers'

Icon = React.createFactory require '../module/icon'
Space = React.createFactory require 'react-lite-space'
MessageRichImage = React.createFactory require '../module/message-rich-image'
RelativeTime = React.createFactory require '../module/relative-time'

{div, pre, a} = React.DOM

module.exports = React.createClass
  displayName: 'team-activity'

  propTypes:
    team: React.PropTypes.instanceOf(Immutable.Map).isRequired
    activity: React.PropTypes.instanceOf(Immutable.Map).isRequired
    showRemove: React.PropTypes.bool.isRequired

  # events

  onClick: ->
    switch @props.activity.get('type')
      when 'story'
        target = @props.activity.get('target')
        handlers.router.story target.get('_teamId'), target.get('_id')
      when 'room'
        target = @props.activity.get('target')
        handlers.router.room target.get('_teamId'), target.get('_id')

  onRemove: (event) ->
    event.stopPropagation()
    actions.activities.remove @props.activity.get('_id')

  onLinkClick: (event) ->
    event.stopPropagation()
    event.preventDefault()
    window.open urlParse event.target.getAttribute('href'), true

  # renderers

  renderStory: (creator, info) ->
    target = @props.activity.get('target')
    switch target.get('category')
      when 'topic' then @renderIdea creator, info
      when 'file'
        fileData = target.get('data')
        if detect.isImageWithPreview(fileData)
          @renderImage creator, info
        else
          @renderFile creator, info
      when 'link' then @renderLink creator, info

  renderFile: (creator, info) ->
    fileStory = @props.activity.get('target')

    div className: 'activity-details',
      div className: 'activity-info',
        creator.get('name')
        Space width: 8
        info
      div className: 'detail-title',
        fileStory.get('title')
      div className: 'detail-text',
        fileStory.get('text')

  renderImage: (creator, info) ->
    fileStory = @props.activity.get('target')

    div className: 'activity-details',
      div className: 'activity-info',
        creator.get('name')
        Space width: 8
        info
      div className: 'detail-title',
        fileStory.get('title')
      MessageRichImage
        attachment: fileStory
        heightBoundary: 312
        widthBoundary: 416
        onClick: @onClick

  renderLink: (creator, info) ->
    linkStory = @props.activity.get('target')
    url = linkStory.getIn ['data', 'url']

    div className: 'activity-details',
      div className: 'activity-info',
        creator.get('name')
        Space width: 8
        info
      div className: 'detail-title',
        linkStory.get('title')
      div className: 'detail-link',
        a href: url, target: '_blank', onClick: @onLinkClick, url

  renderIdea: (creator, info) ->
    div className: 'activity-details',
      div className: 'activity-info',
        creator.get('name')
        Space width: 8
        info
      div className: 'detail-title',
        @props.activity.getIn ['target', 'title']
      div className: 'detail-text',
        @props.activity.getIn ['target', 'text']

  renderRoom: (creator, info) ->
    topic = @props.activity.get('target')
    topicName = topic.get 'topic'
    purpose = topic.get('purpose')

    div className: 'activity-details',
      div className: 'activity-info',
        creator.get('name')
        Space width: 8
        info
      div className: 'detail-title', '#', topicName
      if purpose? and purpose.trim().length > 0
        div className: 'detail-text', purpose

  renderInvitation: (creator, info) ->
    div className: 'activity-details',
      div className: 'activity-info',
        creator.get('name')
        Space width: 8
        info

  renderIcon: ->
    switch @props.activity.get('type')
      when 'story'
        target = @props.activity.get('target')
        switch target.get('category')
          when 'topic'
            div className: 'activity-icon img-circle img-32 is-idea',
              Icon size: 18, name: 'idea'
          when 'link'
            div className: 'activity-icon img-circle img-32 is-link',
              Icon size: 18, name: 'chain'
          when 'file'
            div className: 'activity-icon img-circle img-32 is-file',
              Icon size: 18, name: 'paperclip-lean'
      when 'room'
        div className: 'activity-icon img-circle img-32 is-room',
          Icon size: 18, name: 'sharp'
      else # undefined refers to invitation
        div className: 'activity-icon img-circle img-32 is-invitation',
          Icon size: 18, name: 'horn'

  render: ->
    _teamId = @props.activity.get('_teamId')
    content = @props.activity.get('text')
    .replace /\{\{__([\w-]+)\}\}/g, (raw, key) ->
      text = lang.getText(key)
      if text then text else raw
    creator = @props.activity.get('creator')

    isLog = @props.activity.get('type') is undefined
    className = classnames 'team-activity', (if isLog then 'is-log' else 'is-entry')

    div className: className, onClick: @onClick,
      @renderIcon()
      Space width: 24
      switch @props.activity.get('type')
        when 'story' then @renderStory creator, content
        when 'room' then @renderRoom creator, content
        else @renderInvitation creator, content
      RelativeTime data: @props.activity.get('createdAt')
      if @props.showRemove and (not isLog)
        Icon size: 16, name: 'remove', className: 'activity-remove', onClick: @onRemove
