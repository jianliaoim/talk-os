recorder = require 'actions-recorder'
Immutable = require 'immutable'
dispatcher = require '../dispatcher'

api = require '../network/api'
lookup = require '../util/lookup'
query = require '../query'

mockMessage = require '../util/mock-message'

assembleFileMessage = (fileData, userData) ->
  _toId: userData._toId
  _roomId: userData._roomId
  _teamId: userData._teamId
  _storyId: userData._storyId
  _creatorId: userData._creatorId
  creator: userData.creator
  body: ''
  attachments: [
    category: 'file'
    data:
      fileId: fileData.fileId
      fileKey: fileData.fileKey
      fileName: fileData.fileName
      fileType: fileData.fileType
      fileSize: fileData.fileSize
      fileCategory: fileData.fileCategory
      imageWidth: fileData.imageWidth
      imageHeight: fileData.imageHeight
      downloadUrl: fileData.downloadUrl
      thumbnailUrl: fileData.thumbnailUrl
  ]

exports.fileCreate = (fileInfo, userData) ->
  fakeMessage = mockMessage(assembleFileMessage(fileInfo, userData))
  dispatcher.handleViewAction
    type: 'file/create'
    data: fakeMessage

exports.fileProgress = (progress, fileInfo, userData) ->
  dispatcher.handleViewAction
    type: 'file/progress'
    data:
      fileId: fileInfo.fileId
      userData: userData
      progress: progress

exports.fileSuccess = (fileData, fileInfo, userData) ->
  fileId = fileInfo.fileId
  store = recorder.getStore()
  dispatcher.handleViewAction
    type: 'file/success'
    data:
      fileData: fileData
      fileId: fileId
      userData: userData

  _channelId = lookup.getChannelId Immutable.fromJS userData
  fakeMessage = store.getIn(['messages', userData._teamId, _channelId]).find (message) ->
    fileId is  message.getIn(['attachments', 0, 'data', 'fileId'])

  messageData = assembleFileMessage(fileData, userData)

  api.messages.create.post(data: messageData)
    .then (resp) ->
      # render local image, avoid re-download and re-render the uploaded image
      oldThumbnail = fakeMessage.getIn(['attachments', '0', 'data', 'thumbnailUrl'])
      if oldThumbnail
        resp.attachments[0].data.thumbnailUrl = oldThumbnail

      # don't move the local image
      resp.createdAt = fakeMessage.get('createdAt')
      resp.updatedAt = fakeMessage.get('updatedAt')
      resp.fakeId = fakeMessage.get('_id')

      dispatcher.handleViewAction
        type: 'message/correct'
        data: resp

exports.fileError = (fileInfo, userData) ->
  dispatcher.handleViewAction
    type: 'file/error'
    data:
      fileId: fileInfo.fileId
      userData: userData
