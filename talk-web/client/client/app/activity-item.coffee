cx = require 'classnames'
React = require 'react'
moment = require 'moment'
Immutable = require 'immutable'

actions = require '../actions/index'
handlers = require '../handlers/index'

lang = require '../locales/lang'

{a, i, div, span, strong, time} = React.DOM

module.exports = React.createClass

  propTypes:
    activity: React.PropTypes.instanceOf(Immutable.Map).isRequired

  translateCreator: (creator) ->
    return '' if not creator? or not Immutable.Map.isMap creator
    creator.get('name') or ''

  translateTarget: ->
    return '' if not @props.activity.get 'target'

    switch @props.activity.get 'type'
      when 'room'
        @props.activity.getIn ['target', 'topic']
      when 'story'
        @props.activity.getIn ['target', 'title']
      else
        ''

  translateText: (text) ->
    text.replace /\{\{__([\w-]+)\}\}/g, (raw, key) ->
      text = lang.getText key
      if text then text else raw

  formatTime: (time) ->
    moment(time).format 'MM/DD HH:mm'

  getText: ->
    creatorText = @translateCreator @props.activity.get('creator')
    activityText = @translateText @props.activity.get('text')
    targetText = @translateTarget @props.activity
    span null, "#{creatorText} #{activityText}".trim(),
      if targetText.length > 0
        strong null, ' ' + "#{targetText}".trim()

  onRemoveActivity: (event) ->
    event.stopPropagation()
    isRemovable = window.confirm lang.getText 'delete-activity-confirm'
    if isRemovable
      actions.activities.remove @props.activity.get('_id')

  onRouteToTarget: ->
    switch @props.activity.get('type')
      when 'story'
        target = @props.activity.get('target')
        handlers.router.story target.get('_teamId'), target.get('_id')
      when 'room'
        target = @props.activity.get('target')
        handlers.router.room target.get('_teamId'), target.get('_id')

  renderAvatar: ->
    if @props.activity.get('type')
      style =
        backgroundImage: "url(#{@props.activity.getIn ['creator', 'avatarUrl']})"

    i className: 'activity-item-avatar', style: style,
      @renderType()

  renderType: ->
    type =
      switch @props.activity.get 'type'
        when 'room' then 'sharp'
        when 'story'
          switch @props.activity.getIn ['target', 'category']
            when 'file' then 'paperclip-lean'
            when 'link' then 'chain'
            when 'topic' then 'idea'
        else 'horn'

    style =
      backgroundColor: switch @props.activity.get 'type'
        when 'room' then '#63C7F2'
        when 'story'
          switch @props.activity.getIn ['target', 'category']
            when 'file' then '#A66A95'
            when 'link' then '#67C395'
            when 'topic' then '#FFCB2B'
        else '#AFB0B3'

    i className: "ti ti-#{type}", style: style

  render: ->
    if not @props.activity.get 'type'
      className = 'is-static'

    div className: cx('activity-item', className), onClick: @onRouteToTarget,
      @renderAvatar()
      time className: 'activity-item-time',
        @formatTime @props.activity.get 'createdAt'
      div className: 'activity-item-text text-overflow',
        @getText()
      a className: 'activity-item-remove', onClick: @onRemoveActivity,
        i className: 'ti ti-trash'
