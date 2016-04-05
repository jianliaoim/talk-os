# API:
# accept: '' - default empty string
# multiple: boolean, - default false
# onCreate({file, fileInfo, metaData})
# onProgress({progress, fileInfo, metaData})
# onSuccess({fileData, fileInfo, metaData})
# onError({errorType, fileInfo, metaData})
# metaData - any meta data that should be carried along through the file upload process

Q = require 'q'
shortid = require 'shortid'
assign = require 'object-assign'

api = require '../network/api'
lang = require '../locales/lang'
format = require '../util/format'
uploadUrl = require('../config').uploadUrl

if typeof window isnt 'undefined'
  FileAPI = require 'fileapi'
  gloablInputButton = document.createElement 'input'
  gloablInputButton.type = 'file'

globalToken = null

getToken = ->
  if not globalToken
    Q(api.strikertoken.get())
      .then (resp) ->
        globalToken = resp.token
        globalToken
      .catch ->
        globalToken = null
        Q.reject errorTypes.Token_Error
  else
    Q.when(globalToken)

errorTypes =
  Upload_Error: 'Upload_Error'
  File_Not_Permitted: 'File_Not_Permitted'
  File_Size_Exceeded: 'File_Size_Exceeded'
  Multiple_Not_Allowed: 'Multiple_Not_Allowed'
  Type_Not_Allowed: 'Type_Not_Allowed'
  Unauthorized: 'Unauthorized'
  Token_Error: 'Token_Error'
  Abort: 'Abort'

makeThumbnail = (file, fileInfo) ->
  Q.Promise (resolve) ->
    if fileInfo.fileCategory is 'image' and fileInfo.fileType isnt 'gif'
      imageUrl = window.URL.createObjectURL file
      simpleImageEl = new window.Image
      simpleImageEl.onload = ->
        image = FileAPI.Image file
        # FileAPI loads image into Canvas
        image.get (err, imageEL) ->
          if err
            # don't make a thumbnail
            resolve(fileInfo)
          else
            src = imageEL.toDataURL()
            fileInfo.downloadUrl = fileInfo.thumbnailUrl = src
            fileInfo.imageWidth = imageEL.width
            fileInfo.imageHeight = imageEL.height
            fileInfo.size = file.size
            resolve(fileInfo)
      simpleImageEl.src = imageUrl
    else
      resolve(fileInfo)

mockFileInfo = (file) ->
  fileId: shortid.generate()
  downloadUrl: null
  fileCategory: file.type.split('/')[0]
  fileKey: null
  fileName: file.name
  fileSize: file.size
  fileType: file.type.split('/')[1]
  imageWidth: 0
  imageHeight: 0
  thumbnailUrl: null

checkMultipleFiles = (files, config) ->
  Q.Promise (resolve, reject) ->
    if (not config.multiple) and files.length > 1
      reject errorTypes.Multiple_Not_Allowed
    else
      resolve(files)

checkSingleFile = (file, config) ->
  Q.Promise (resolve, reject) ->
    # striker 文件上传限制1G
    # https://github.com/server/striker2/blob/master/services/file.js#L19
    if file.size >= 1024 * 1024 * 1024
      reject errorTypes.File_Size_Exceeded

    if config.accept
      extensions = config.accept.split(',').map (e) -> e.slice(1)
      isValidType = extensions.some (e) ->
        file.type.split('/').indexOf(e) >= 0
      if not isValidType
        reject errorTypes.Type_Not_Allowed

    resolve(file)

uploadFile = (file, fileInfo, token, config, onCreate) ->
  Q.Promise (resolve, reject, notify) ->
    FileAPI.upload
      url: "#{uploadUrl}/upload"
      headers:
        authorization: token
      data:
        size: file.size
      files:
        file: file
      fileupload: (file, xhr, options) ->
        onCreate file, fileInfo, xhr
      fileprogress: (event) ->
        notify (event.loaded / event.total)
      filecomplete: (err, xhr, file) ->
        if xhr.status is 401 # 权限不足
          globalToken = null
          reject errorTypes.Unauthorized
        else if xhr.status >= 400
          reject errorTypes.Upload_Error
        else if xhr.status is 0
          reject errorTypes.Abort
        else if err
          window.onerror? "file complete err: #{err} #{JSON.stringify(xhr)}"
          reject errorTypes.Upload_Error
        else
          Q.try ->
            JSON.parse xhr.responseText
          .catch ->
            reject errorTypes.Upload_Error
          .then (res) ->
            if res?.fileKey?.length
              resolve res
            else
              reject errorTypes.Upload_Error

uploadFiles = (files, config) ->
  config.multiple = config.multiple or false
  config.accept = config.accept or ''
  onCreate = (file, fileInfo, xhr) ->
    config.onCreate? assign({file, fileInfo, xhr}, metaData: config.metaData)
  onProgress = (progress, fileInfo) ->
    config.onProgress? assign({progress, fileInfo}, metaData: config.metaData)
  onSuccess = (fileData, fileInfo) ->
    config.onSuccess? assign({fileData, fileInfo}, metaData: config.metaData)
  onError = (error, fileInfo) ->
    config.onError? assign({error, fileInfo}, metaData: config.metaData)

  # main file upload logic
  Q.all [checkMultipleFiles(files, config), getToken()]
    .catch onError
    .spread (files, token) ->
      files.forEach (file) ->
        fileInfo = mockFileInfo(file)
        Q.all [checkSingleFile(file, config), makeThumbnail(file, fileInfo)]
          .spread (file, thumbnailInfo) ->
            fileInfo = thumbnailInfo
            uploadFile file, fileInfo, token, config, onCreate
          .catch (error) ->
            onError error, fileInfo
            return
          .progress (progress) ->
            onProgress progress, fileInfo
          .then (fileData) ->
            if fileData
              onSuccess fileData, fileInfo
          .done()
    .done()

handlePasteEvent = (event, config) ->
  items = event.clipboardData.items
  return if not items
  files = for item in items
    file = item.getAsFile()
    if FileAPI.isBlob(file)
      file.lastModifiedDate = new Date()
      file.name = 'paste'
    file
  files = files.filter (file) -> file?
  if files.length > 0
    event.preventDefault()
    uploadFiles files, config

handleFileDropping = (target, config) ->
  onFilesLoad = (files) -> uploadFiles files, config
  onFileHover = (isHover) -> config.onFileHover? isHover
  FileAPI.event.dnd target, onFileHover, onFilesLoad

handleClick = (config) ->
  gloablInputButton.multiple = config.multiple or false
  gloablInputButton.accept = config.accept or ''
  gloablInputButton.onchange = (event) ->
    # rewrite method to inject null value
    oldOnSuccess = config.onSuccess
    oldOnError = config.onError
    config.onSuccess = ->
      oldOnSuccess.apply null, arguments
      gloablInputButton.value = null
    config.onError =  ->
      oldOnError.apply null, arguments
      gloablInputButton.value = null

    files = FileAPI.getFiles event
    uploadFiles files, config
  gloablInputButton.click()

module.exports =
  errorTypes: errorTypes
  uploadFiles: uploadFiles
  handleClick: handleClick
  handlePasteEvent: handlePasteEvent
  handleFileDropping: handleFileDropping
