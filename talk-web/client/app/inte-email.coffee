React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

query = require '../query'
lang = require '../locales/lang'

CopyArea = React.createFactory require('react-lite-misc').Copyarea

TopicSelector = React.createFactory require '../app/topic-selector'
mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'
mixinInteEvents = require '../mixin/inte-events'

div  = React.createFactory 'div'
span = React.createFactory 'span'
img = React.createFactory 'img'
a = React.createFactory 'a'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'inte-email'
  mixins: [
    LinkedStateMixin
    mixinCreateTopic, mixinInteHandler, mixinInteEvents
    PureRenderMixin
  ]

  propTypes:
    _teamId: T.string
    _roomId: T.string
    settings: T.object
    inte:     T.instanceOf(Immutable.Map)
    onPageBack: T.func

  renderBody: (topic) ->
    div className: 'settings',
      div className: 'topic',
        div className: 'description',
          span className: 'line', l('inte-email-address')
          span className: 'line muted', l('inte-email-address－description')
        CopyArea text: topic.get('email')

  render: ->
    topic = query.topicsByOne(recorder.getState(), @props._teamId, @state._roomId)
    email = topic.get('email')

    if topic.get('isGeneral')
      fillText = lang.getText('room-general')
    else
      fillText = topic.get('topic')
    text = lang.getText('email-message-%s').replace('%s', fillText)
    div className: 'inte-email',
      div className: 'inte-board lm-content',
        @renderInteHeader()
        @renderTopicRow()
        @renderTopicCreate()
        @renderBody topic
