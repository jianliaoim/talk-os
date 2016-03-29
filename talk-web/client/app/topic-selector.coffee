React = require 'react'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang        = require '../locales/lang'

detect = require '../util/detect'

mixinSubscribe = require '../mixin/subscribe'

LiteDropdown = React.createFactory require 'react-lite-dropdown'
div = React.createFactory 'div'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'topic-selector'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId:      T.string.isRequired
    chosen:       T.string.isRequired
    onItemClick:  T.func.isRequired

  getInitialState: ->
    topics: @getTopics()
    showMenu: false

  componentDidMount: ->
    @subscribe recorder, =>
      @setState topics: @getTopics()

  getTopics: ->
    query.topicsBy(recorder.getState(), @props._teamId)

  getTopicName: (topic) ->
    if topic.get('isGeneral')
      lang.getText('room-general')
    else
      topic.get('topic')

  getChosenName: ->
    targetRoom = @state.topics.find (topic) =>
      topic.get('_id') is @props.chosen
    if targetRoom?
      @getTopicName targetRoom
    else null

  onMenuToggle: ->
    @setState showMenu: (not @state.showMenu)

  renderTopics: ->
    _userId = query.userId(recorder.getState())

    @state.topics
    .filter (room) ->
      detect.inChannel(room)
    .map (topic) =>
      onClick = =>
        @props.onItemClick topic.get('_id')
      div key: topic.get('_id'), className: 'item', onClick: onClick, @getTopicName(topic)

  render: ->
    LiteDropdown
      displayText: if @props.chosen? then @getChosenName()
      defaultText: lang.getText('choose-a-topic')
      name: 'topic-selector'
      show: @state.showMenu
      onToggle: @onMenuToggle
      @renderTopics()
