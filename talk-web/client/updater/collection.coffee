
lookup = require '../util/lookup'

exports.file = (store, actionData) ->
  _userId = store.getIn ['user', '_id']
  _teamId = actionData.getIn ['data', '_teamId']
  messagesList = actionData.get('messages')
  _channelId = lookup.getMessageChannelId actionData.get('data'), _userId

  store.setIn ['fileMessages', _teamId, _channelId], messagesList

exports.post = (store, actionData) ->
  _userId = store.getIn ['user', '_id']
  _teamId = actionData.getIn ['data', '_teamId']
  messagesList = actionData.get('messages')
  _channelId = lookup.getMessageChannelId actionData.get('data'), _userId

  store.setIn ['postMessages', _teamId, _channelId], messagesList

exports.link = (store, actionData) ->
  _userId = store.getIn ['user', '_id']
  _teamId = actionData.getIn ['data', '_teamId']
  messagesList = actionData.get('messages')
  _channelId = lookup.getMessageChannelId actionData.get('data'), _userId

  store.setIn ['linkMessages', _teamId, _channelId], messagesList

exports.snippet = (store, actionData) ->
  _userId = store.getIn ['user', '_id']
  _teamId = actionData.getIn ['data', '_teamId']
  messagesList = actionData.get('messages')
  _channelId = lookup.getMessageChannelId actionData.get('data'), _userId

  store.setIn ['snippetMessages', _teamId, _channelId], messagesList
