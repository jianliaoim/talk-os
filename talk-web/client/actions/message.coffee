assign = require 'object-assign'
recorder = require 'actions-recorder'
Q = require 'q'

dispatcher = require '../dispatcher'

TALK = require '../config'
notifyActions = require '../actions/notify'
api = require '../network/api'
query = require '../query'

lang = require '../locales/lang'

mockMessage = require '../util/mock-message'
analytics = require '../util/analytics'

messageActionCommands = require('../app/command-menu').commands.filter (command) ->
  command.has('action')

processMessageActionCommands = (data, _teamId) ->
  command = messageActionCommands.find (c) ->
    data.body and data.body.indexOf(c.get('trigger')) is 0
  action =
    if data.body and command?.get('action')
      command.get('action')(data).then (modifiedData) ->
        {command, data: modifiedData}
    else
      Q.when({data})

exports.messageMore = (data, success, fail) ->
  api.messages.read.get(queryParams: data)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'message/more'
        data: {channel: data, data: resp}
      success? resp
    .catch (error) ->
      fail? error

exports.requestMore = (data, success, fail) ->
  api.messages.read.get(queryParams: data)
    .then (resp) ->
      success resp
    .catch (error) ->
      console.error 'message.requestMore', error
      fail? error

exports.messageCreate = (data, success, fail) ->
  analytics.trackMessageSent()

  processMessageActionCommands(data)
    .then ({data, command}) ->
      data.creator = query.user(recorder.getState()).toJS()
      fakeMessage = mockMessage data
      dispatcher.handleViewAction
        type: 'message/create'
        data: fakeMessage
      if command?.get('isFake')
        success? fakeMessage
        Q.when()
      else
        api.messages.create.post(data: data)
          .then (resp) ->
            resp.fakeId = fakeMessage._id
            dispatcher.handleViewAction
              type: 'message/correct'
              data: resp
            success? resp
          .catch (error) ->
            fail? error
    .done()

exports.createLocal = (data) ->
  fakeMessage = mockMessage data
  dispatcher.handleViewAction
    type: 'message/create-local'
    data: fakeMessage

exports.messageUpdate = (messageId, data, success, fail) ->
  config =
    pathParams:
      id: messageId
    data: data
  api.messages.update.put(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'message/update'
        data: resp
      success? resp
    .catch (error) ->
      fail? error

exports.messageDelete = (message, success, fail) ->
  api.messages.remove.delete(pathParams: id: message.get('_id'))
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'message/remove'
        data: message
      success? resp
    .catch (error) ->
      fail? error

exports.deleteLocal = (message) ->
  dispatcher.handleViewAction
    type: 'message/remove'
    data: message

exports.messageReadChat = (_teamId, userId, success, fail) ->
  config =
    queryParams:
      _teamId: _teamId
      _toId: userId
  api.messages.read.get(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'contact/fetch'
        data: {_teamId: _teamId, _toId: userId, data: resp}
      success? resp
    .catch (error) ->
      fail? error

exports.starMessage = (_messageId, success, fail) ->
  api.messages.star.post(pathParams: id: _messageId)
    .then (resp) ->
      success? resp
    .catch (error) ->
      fail? error

exports.unstarMessage = (_messageId, success, fail) ->
  api.messages.unstar.post(pathParams: id: _messageId)
    .then (resp) ->
      success? resp
    .catch (error) ->
      fail? error

exports.messageForward = ({_messageId, _teamId, _roomId, _toId}) ->
  user = query.user(recorder.getState())
  params = { _teamId, _roomId, _toId }

  pathParams = id: _messageId

  api.messages.repost.post(data: params, pathParams: pathParams)
    .then (resp) ->
      notifyActions.success lang.getText('success-forwarding-message')
    .catch (error) ->
      notifyActions.error lang.getText('failed-forwarding-message'), isSticky: true

exports.outdatedExcept = (_teamId, _channelId) ->
  dispatcher.handleViewAction
    type: 'message/outdated-except'
    data: {_teamId, _channelId}

exports.read = (_teamId, _channelId, _channelType, success, fail) ->
  targetChannel =
    switch _channelType
      when 'chat' then _toId: _channelId
      when 'room' then _roomId: _channelId
      when 'story' then _storyId: _channelId

  config = queryParams: assign { _teamId }, targetChannel

  api.messages.read.get(config)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'message/read'
        data: assign config.queryParams,
          { data: resp }
      success? resp
    .catch (error) ->

exports.receipt = (message, _userId, success, fail) ->
  mentions = message.get('mentions')
  receiptors = message.get('receiptors')
  mentionedMe = mentions?.includes _userId
  hasRead = receiptors?.includes _userId

  if mentionedMe and not hasRead
    dispatcher.handleViewAction
      type: 'message/receipt-loading'
      data: message

    api.messages.receipt.post(pathParams: id: message.get('_id'))
      .then (resp) ->
        dispatcher.handleViewAction
          type: 'message/update'
          data: resp
        success?()
      .catch ->
        dispatcher.handleViewAction
          type: 'message/update'
          data: message
        fail?()

# special method for guest page
exports.messageClear = (data, success, fail) ->
  # unread in guest page is mocked with local state, don't communicate to server
  dispatcher.handleViewAction
    type: 'guest-topic/clear'
    data: data
