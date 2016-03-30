cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

detect = require '../util/detect'
colors = require '../util/colors'

TopicCorrection = React.createFactory require './topic-correction'

Icon = React.createFactory require '../module/icon'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'topic-name'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    topic:          T.instanceOf(Immutable.Map)
    onClick:        T.func
    colorizePlace:  T.string
    active:         T.bool
    hover:          T.bool
    showPurpose:    T.bool
    showUnread:     T.bool
    showGuest:      T.bool
    showMute:       T.bool
    showIcon:       T.bool
    showQuit:       T.bool

  getDefaultProps: ->
    onClick:        ->
    colorizePlace:  'background'
    active:         false
    hover:          false
    showPurpose:    false
    showUnread:     false
    showGuest:      false
    showMute:       false
    showIcon:       true
    showQuit:       false

  getInitialState: ->
    isMute: @getMute()

  componentDidMount: ->
    @subscribe recorder, => @setState isMute: @getMute()

  getMute: ->
    prefs = query.topicPrefsBy(recorder.getState(), @props.topic.get('_teamId'), @props.topic.get('_id'))
    isMute = prefs?.get('isMute') or false

  onClick: (event) ->
    # event.stopPropagation()
    @props.onClick @props.topic.get('_id')

  renderIcon: ->
    return unless @props.showIcon

    isGeneral = @props.topic.get('isGeneral')
    isPrivate = @props.topic.get('isPrivate')

    iconClass =
      if not isGeneral and isPrivate
        'ti is-leading ti-lock-solid'
      else
        'ti is-leading ti-sharp'
    style =
      if @props.colorizePlace is 'background'
        backgroundColor: colors.blue
      else # font
        color: colors.blue
    span className: iconClass, style: style

  renderTopic: ->
    TopicCorrection
      topic: @props.topic

  renderStates: ->
    if @props.showPurpose and @props.topic.get('purpose')?
      div className: 'states',
        span className: 'short purpose', @props.topic.get('purpose')

  renderUnread: ->
    unread = @props.topic.get('unread')
    if @props.showMute and @state.isMute
      div className: 'mutetip',
        span className: cx 'ti', 'ti-mute', 'unread': unread
    else if @props.showUnread and unread and not @state.isMute
      span className: 'icon-unread', unread

  renderQuit: ->
    if @props.showQuit and not detect.inChannel(@props.topic)
      span className: 'muted flex-static hint', lang.getText('no-in-topic')

  renderSelect: ->
    if @props.active
      Icon name: 'tick', size: 18, className: 'flex-static'

  render: ->
    className = cx 'banner', 'topic-name', 'item', 'line',
      'hover': @props.hover

    div onClick: @onClick, className: className,
      @renderIcon()
      @renderTopic()
      @renderStates()
      @renderUnread()
      @renderQuit()
      @renderSelect()
