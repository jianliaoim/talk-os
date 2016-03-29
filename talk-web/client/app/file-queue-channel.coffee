React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

messageActions = require '../actions/message'

mixinFileQueue = require '../mixin/file-queue'
mixinSubscribe = require '../mixin/subscribe'

orders = require '../util/orders'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-queue-channel'
  mixins: [mixinFileQueue, mixinSubscribe, PureRenderMixin]

  propTypes:
    # used in mixin
    messages: T.instanceOf(Immutable.List)
    onClose: T.func.isRequired
    attachment: T.instanceOf(Immutable.Map)
    # used in component
    _teamId: T.string.isRequired
    _roomId: T.string
    _toId: T.string
    _storyId: T.string

  requestBefore: (success) ->
    messageIds = @state.queue.map (x) -> x.getIn(['message', '_id'])
    data =
      _teamId: @props._teamId
      _maxId: messageIds.min()
    # reqwest has some problem handling undefind propeties
    if @props._roomId?
      data._roomId = @props._roomId
    if @props._toId?
      data._toId = @props._toId
    if @props._storyId?
      data._storyId = @props._storyId
    messageActions.requestMore data, (resp) ->
      messages = Immutable.fromJS(resp)
      .concat()
      .sort(orders.imMsgByCreatedAtWithId)
      success messages

  requestAfter: (success) ->
    messageIds = @state.queue.map (x) -> x.getIn(['message', '_id'])
    data =
      _teamId: @props._teamId
      _minId: messageIds.max()
    # reqwest has some problem handling undefind propeties
    if @props._roomId?
      data._roomId = @props._roomId
    if @props._toId?
      data._toId = @props._toId
    if @props._storyId?
      data._storyId = @props._storyId
    messageActions.requestMore data, (resp) ->
      messages = Immutable.fromJS(resp)
      .concat()
      .sort(orders.imMsgByCreatedAtWithId)
      success messages

  render: ->
    @renderQueue()
