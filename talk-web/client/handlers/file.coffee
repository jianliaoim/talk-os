
recorder = require 'actions-recorder'

lang = require '../locales/lang'
query = require '../query'
config = require '../config'

format = require '../util/format'
upload = require '../util/upload'
analytics = require '../util/analytics'

eventBus = require '../event-bus'
fileActions = require '../actions/file'
notifyActions = require '../actions/notify'

exports.getNewMessageInfo = ->
  store = recorder.getStore()
  routerData = store.getIn ['router', 'data']
  user = store.get 'user'

  if config.isGuest
    topic = query.guestOnlyTopic store
    _teamId: topic.get('_teamId')
    _roomId: topic.get('_id')
    _creatorId: user.get('_id')
    creator: user
  else
    _teamId: routerData.get('_teamId')
    _roomId: routerData.get('_roomId')
    _toId: routerData.get('_toId')
    _storyId: routerData.get('_storyId')
    _creatorId: user.get('_id')
    creator: user

cache = {}
deleteCacheKey = (fileId) ->
  if cache[fileId]
    cache[fileId] = undefined

exports.create = ({fileInfo, metaData, xhr}) ->
  cache[fileInfo.fileId] = xhr

  fileActions.fileCreate fileInfo, metaData
  window.requestAnimationFrame ->
    eventBus.emit 'dirty-action/new-message'

exports.abort = ({fileInfo}) ->
  xhr = cache[fileInfo.fileId]
  if xhr
    xhr.abort()

exports.progress = ({progress, fileInfo, metaData}) ->
  fileActions.fileProgress progress, fileInfo, metaData

exports.success = ({fileData, fileInfo, metaData}) ->
  deleteCacheKey(fileInfo.fileId)
  fileActions.fileSuccess fileData, fileInfo, metaData
  analytics.mixpanel 'file success',
    fileSize: fileData.fileSize
    fileCategory: fileData.fileCategory
    imageWidth: fileData.imageWidth
    imageHeight: fileData.imageHeight
    mimeType: fileData.mimeType

exports.error = ({error, fileInfo, metaData}) ->
  console.error arguments

  localeKey = switch error
    when upload.errorTypes.File_Not_Permitted
      'uploader-files-not-accept'
    when upload.errorTypes.File_Size_Exceeded
      'uploader-files-exceed-size'
    when upload.errorTypes.Type_Not_Allowed
      'uploader-type-not-allowed'
    when upload.errorTypes.Multiple_Not_Allowed
      'uploader-files-limit-size'
    when upload.errorTypes.Token_Error
      'uploader-error'
    when upload.errorTypes.Abort
      null
    else
      'uploader-error'

  if localeKey
    notifyText = lang.getText(localeKey)
    if fileInfo
      notifyText += ": #{fileInfo.fileName}"

  if notifyText
    notifyActions.error notifyText

  if fileInfo # 检查多文件的时候还没有fileInfo
    deleteCacheKey(fileInfo.fileId)
    fileActions.fileError fileInfo, metaData
