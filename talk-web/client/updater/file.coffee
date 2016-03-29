Immutable = require 'immutable'
lookup = require '../util/lookup'
query = require '../query'

exports.create = (store, fakeMessage) ->
  _teamId = fakeMessage.get('_teamId')
  _channelId = lookup.getMessageChannelId(fakeMessage, query.userId(store))

  newMessage = fakeMessage
    .setIn(['attachments', 0, 'isUploading'], true)
    .setIn(['attachments', 0, 'progress'], 0)

  updatePath = ['messages', _teamId, _channelId]

  if store.hasIn(updatePath)
    store = store.updateIn updatePath, (messages) ->
      messages.push newMessage

  store

exports.progress = (store, actionData) ->
  fileId = actionData.get('fileId')
  userData = actionData.get('userData')
  _teamId = userData.get('_teamId')
  _channelId = lookup.getMessageChannelId(userData, query.userId(store))
  progress = actionData.get('progress')

  updatePath = ['messages', _teamId, _channelId]

  if store.hasIn(updatePath)
    store = store.updateIn updatePath, (messages) ->
      messages.map (message) ->
        if fileId is message.getIn(['attachments', 0, 'data', 'fileId'])
          message.setIn(['attachments', 0, 'progress'], progress)
        else
          message

  store

exports.success = (store, actionData) ->
  fileId = actionData.get('fileId')
  fileData = actionData.get('fileData')
  userData = actionData.get('userData')
  _teamId = userData.get('_teamId')
  _channelId = lookup.getMessageChannelId(userData, query.userId(store))

  updatePath = ['messages', _teamId, _channelId]

  if store.hasIn(updatePath)
    store = store.updateIn updatePath, (messages) ->
      messages.map (message) ->
        if fileId is message.getIn(['attachments', 0, 'data', 'fileId'])
          message.updateIn ['attachments', 0, 'data'], (prevFileData) ->
            fileData.set 'thumbnailUrl', prevFileData.get('thumbnailUrl')
        else
          message

  store

exports.error = (store, actionData) ->
  fileId = actionData.get('fileId')
  userData = actionData.get('userData')
  _teamId = userData.get('_teamId')
  _channelId = lookup.getMessageChannelId(userData, query.userId(store))

  updatePath = ['messages', _teamId, _channelId]

  if store.hasIn(updatePath)
    store = store.updateIn updatePath, (messages) ->
      messages.filterNot (message) ->
        fileId is message.getIn(['attachments', 0, 'data', 'fileId'])

  store
