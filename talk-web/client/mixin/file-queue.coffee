classnames = require 'classnames'
Immutable = require 'immutable'
keycode = require 'keycode'
React = require 'react'
recorder = require 'actions-recorder'
urlParse = require 'url-parse'

query = require '../query'

lang = require '../locales/lang'

orders = require '../util/orders'
analytics = require '../util/analytics'
deviceActions = require '../actions/device'

FileAudio = React.createFactory require '../app/file-audio'
FileDefault = React.createFactory require '../app/file-default'
FileImage = React.createFactory require '../app/file-image'
FileInfo = React.createFactory require '../app/file-info'
FilePdf = React.createFactory require '../app/file-pdf'
FileText = React.createFactory require '../app/file-text'
FileVideo = React.createFactory require '../app/file-video'

span = React.createFactory 'span'
div = React.createFactory 'div'

l = lang.getText
T = React.PropTypes

module.exports =

  getInitialState: ->
    queue = @getFileQueue(@props.messages)
    loadingBefore: false
    loadingAfter: false
    noBefore: false
    noAfter: false
    queue: queue
    currentIndex: @getCurrentIndex(queue, @props.attachment.get('_id'))

  componentDidMount: ->
    # TODO: bad idea to send actions in lifecycles
    @checkBefore()
    @checkAfter()

    window.addEventListener 'keydown', @onWindowKeydown


  componentWillUnmount: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  componentWillReceiveProps: (nextProps) ->
    # 如果文件被其他人删除了， 那么关闭这个file-queue
    currentMessageId = @state.queue.getIn([@state.currentIndex, 'message', '_id'])
    isDeleted = not nextProps.messages.some (message) ->
      message.get('_id') is currentMessageId
    if isDeleted
      @onClose()
    else
      queue = @getFileQueue(nextProps.messages)
      @setState
        queue: queue
        currentIndex: @getCurrentIndex(queue, @props.attachment.get('_id'))

  # implement them in components
  # requestBefore: ->
  # requestAfter: ->

  getFileQueue: (messages) ->
    messages.map (message) ->
      message.get('attachments')
      .filter (attachment) ->
        attachment.get('category') is 'file'
      .map (attachment) ->
        Immutable.Map {message, attachment}
    .filterNot (arr) ->
      arr.size is 0
    .flatten(true)

  getCurrentIndex: (queue, attachmentId) ->
    queue.findIndex (cursor) ->
      cursor.getIn(['attachment', '_id']) is attachmentId

  hasPrev: ->
    nextIndex = @state.currentIndex - 1
    nextIndex >= 0

  hasNext: ->
    nextIndex = @state.currentIndex + 1
    nextIndex <= @state.queue.size - 1

  checkBefore: ->
    return if @hasPrev()
    return if @state.noBefore
    @requestBefore (resp) =>
      newQueue = @getFileQueue resp
      if newQueue.size is 0
        @setState noBefore: true
        return
      currentIndex = @state.currentIndex + newQueue.size
      @setState
        currentIndex: currentIndex
        queue: newQueue.concat @state.queue

  checkAfter: ->
    return if @hasNext()
    return if @state.noAfter
    @requestAfter (resp) =>
      newQueue = @getFileQueue resp
      if newQueue.size is 0
        @setState noAfter: true
        return
      @setState
        queue: @state.queue.concat newQueue

  onSwitchLeft: (event) ->
    analytics.modalFileSwitchLeft()
    event.stopPropagation()
    if @hasPrev()
      @setState
        currentIndex: @state.currentIndex - 1
        @checkBefore
      # check prev after setState

  onSwitchRight: (event) ->
    analytics.modalFileSwitchRight()
    event.stopPropagation()
    if @hasNext()
      @setState
        currentIndex: @state.currentIndex + 1
        @checkAfter
      # check next after setState

  onClose: ->
    @props.onClose()

  onWindowKeydown: (event) ->
    switch keycode(event.keyCode)
      when 'left'
        event.preventDefault()
        @onSwitchLeft event
      when 'right'
        event.preventDefault()
        @onSwitchRight event

  renderLeftCircle: ->
    leftClass = classnames 'side-column', 'is-active': @hasPrev()
    div className: leftClass, onClick: @onBackClick,
      div className: 'side-container', onClick: @onSwitchLeft,
        span className: 'icon icon-chevron-left'

  renderRightCircle: ->
    rightClass = classnames 'side-column', 'is-active': @hasNext()
    div className: rightClass, onClick: @onBackClick,
      div className: 'side-container', onClick: @onSwitchRight,
        span className: 'icon icon-chevron-right'

  renderFileTypes: ->
    file = @state.queue.getIn([@state.currentIndex, 'attachment', 'data'])

    element =
      switch
        when file.get('fileCategory') is 'image' and file.get('thumbnailUrl')
          FileImage
            file: file
            key: file.get('_id')
        when file.get('fileCategory') is 'text'
          FileText
            file: file
            key: file.get('_id')
        when urlParse(file.get('previewUrl') or '').pathname.split('.').pop() is 'pdf' \
        or file.get('fileType') is 'pdf'
          FilePdf
            file: file
            key: file.get('_id')
        when file.get('fileCategory') is 'audio'
          FileAudio
            file: file
            key: file.get('_id')
        when file.get('fileCategory') is 'video'
          FileVideo
            file: file
            key: file.get('_id')
        # not finished yet: mp3, mp4
        else FileDefault file: file
    div className: 'file-container', element

  renderFileInfo: ->
    currentMessage = @state.queue.getIn([@state.currentIndex, 'message'])
    currentAttachment = @state.queue.getIn([@state.currentIndex, 'attachment'])
    FileInfo
      message: currentMessage
      attachment: currentAttachment
      isFavorite: @props.isFavorite

  renderQueue: ->
    div className: 'file-queue',
      span className: 'button-close icon icon-remove', onClick: @onClose
      div className: 'body',
        @renderLeftCircle()
        @renderFileTypes()
        @renderRightCircle()
      @renderFileInfo()
