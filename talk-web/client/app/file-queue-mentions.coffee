React = require 'react'
assign = require 'object-assign'
Immutable = require 'immutable'

mentionedMessageActions = require '../actions/mentioned-message'

mixinFileQueue = require '../mixin/file-queue'
mixinSubscribe = require '../mixin/subscribe'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-queue-mentions'
  mixins: [mixinFileQueue, mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    onClose: T.func.isRequired
    messages: T.instanceOf(Immutable.List)
    attachment: T.instanceOf(Immutable.Map)
    query: T.object

  requestBefore: (success) ->
    success Immutable.List()

  requestAfter: (success) ->
    if @props.query?
      mentionedMessageActions.read @props.query

  render: ->
    @renderQueue()
