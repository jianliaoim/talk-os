React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lookup = require '../util/lookup'
analytics = require '../util/analytics'
deviceActions = require '../actions/device'
messageActions = require '../actions/message'

MessageEditor = React.createFactory require './message-editor'

{div} = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-inline-editor'
  mixins: [PureRenderMixin]

  propTypes:
    message: T.instanceOf(Immutable.Map).isRequired

  componentWillUnmount: ->
    if @props.message.get('_id') is query.getEditMessageId(recorder.getState())
      deviceActions.setEditMessageId(null)

  onSubmit: (text) ->
    if @props.message.get('body') isnt text
      analytics.editMessage()
      messageActions.messageUpdate @props.message.get('_id'), body: text, ->
        deviceActions.setEditMessageId(null)
    else
      deviceActions.setEditMessageId(null)

  render: ->
    MessageEditor
      _toId: @props.message.get('_toId')
      _roomId: @props.message.get('_roomId')
      _teamId: @props.message.get('_teamId')
      _channelId: lookup.getChannelId(@props.message)
      _channelType: lookup.getChannelId(@props.message)
      message: @props.message
      onSubmit: @onSubmit
      isEditMode: true
