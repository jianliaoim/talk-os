React = require 'react'
Immutable = require 'immutable'
FileAPI = require 'fileapi'
uploadUtil  = require '../util/upload'

handlers = require '../handlers'

config = require '../config'
format = require '../util/format'
constraint = require '../util/constraint'

Icon = React.createFactory require './icon'
UploadCircle = React.createFactory require './upload-circle'

{ i, div, span, img } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'uploader'

  propTypes:
    data: T.instanceOf(Immutable.Map).isRequired
    onCreate: T.func
    onComplete: T.func

  getDefaultProps: ->
    onCreate: (->)
    onComplete: (->)

  getInitialState: ->
    progress: 0
    isHover: false

  componentDidMount: ->
    FileAPI.event.dnd @refs.root, @onIsHover, @onFilesLoad

  # user methods

  getOptions: ->
    onCreate: @onCreate
    onProgress: @onProgress
    onSuccess: @onComplete
    onError: handlers.fileError

  # events

  onComplete: ({fileData}) ->
    @props.onComplete fileData

  onCreate: ({fileInfo}) ->
    @props.onCreate fileInfo

  onProgress: ({progress}) ->
    @setState progress: progress

  onFileClick: ->
    uploadUtil.handleClick @getOptions()

  onIsHover: (isHover) ->
    if @isHover isnt @state.isHover
      @setState {isHover}

  onFilesLoad: (files) ->
    uploadUtil.uploadFiles files, @getOptions()

  # renderers

  renderPlaceholder: ->
    if @props.data.get('fileKey')?.length is 0
      div className: 'placeholder flex-vert flex-center flex-vcenter',
        UploadCircle progress: @state.progress,
          span className: 'btn-upload flex-vert flex-center flex-vcenter',
            Icon name: 'cloud-upload', size: 24

  renderProgress: ->
    if @state.progress > 0 and @state.progress < 1
      progressStyle = width: "#{ @state.progress * 100 }%"
      div className: 'progress', style: progressStyle

  render: ->
    div ref: 'root', className: 'uploader', onClick: @onFileClick,
      @renderPlaceholder()
      if @state.isHover
        div className: 'uploader-cover'
