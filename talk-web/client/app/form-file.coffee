cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

constraint = require '../util/constraint'
detect = require '../util/detect'

Icon = React.createFactory require '../module/icon'
Uploader = React.createFactory require '../module/uploader'
Textarea = React.createFactory require 'react-textarea-autosize'

{ a, i, div, form, span, input, fieldset, noscript, textarea } = React.DOM
T = React.PropTypes

PROTO_DATA =
  text: ''
  fileKey: ''
  fileName: ''
  fileSize: ''
  fileType: ''
  imageWidth: ''
  previewUrl: ''
  downloadUrl: ''
  imageHeight: ''
  fileCategory: ''
  thumbnailUrl: ''

module.exports = React.createClass
  displayName: 'form-file'

  propTypes:
    data: T.instanceOf(Immutable.Map)
    onChange: T.func
    onSubmit: T.func
    readOnly: T.bool
    imageWidth: T.number
    onUploaded: T.func
    willSubmit: T.bool
    imageHeight: T.number
    displayMode: T.oneOf([ 'create', 'edit' ]).isRequired
    onDelete: T.func
    onImageClick: T.func

  getDefaultProps: ->
    onChange: (->)
    onDelete: (->)
    onSubmit: (->)
    onImageClick: (->)
    readOnly: false
    imageWidth: 600
    onUploaded: (->)
    willSubmit: false
    imageHeight: 400

  getInitialState: ->
    data: @props.data or Immutable.Map PROTO_DATA
    isUploaded: @props.data?

  componentWillReceiveProps: (nextProps) ->
    if not @props.willSubmit and nextProps.willSubmit
      @props.onSubmit @state.data

    if not nextProps.data?
      @setState
        data: Immutable.Map PROTO_DATA
        isUploaded: false

    if @props.displayMode is 'edit'
      if not @props.readOnly and nextProps.readOnly
        @setState
          data: @props.data or Immutable.Map PROTO_DATA
          isUploaded: @props.data?

  getPreviewSize: ->
    @refs.preview?.getBoundingClientRect() or {}

  isFileClickable: ->
    @props.readOnly and detect.isImageWithPreview(@props.data)

  willChange: (key, value) ->
    newState =
      data: @state.data.set key, value

    @setState newState
    @props.onChange newState.data

  handleFileDelete: (event) ->
    event.stopPropagation()

    newState =
      data: Immutable.Map PROTO_DATA
      isUploaded: false

    @setState newState
    @props.onChange newState.data
    @props.onDelete()

  handleFileView: (event) ->


  handleFileComplete: (uploadedData) ->
    newState =
      data: Immutable.Map uploadedData
      isUploaded: true

    @setState newState
    @props.onChange newState.data
    @props.onUploaded()

  handleFileNameChange: (event) ->
    @willChange 'fileName', event.target.value

  handleTextChange: (event) ->
    @willChange 'text', event.target.value

  onFormSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit @state.data


  renderPreview: ->
    imageWidth = @props.imageWidth
    imageHeight = @props.imageHeight
    thumbnailUrl = @state.data.get 'thumbnailUrl'

    isWidther = @state.data.get('imageWidth') > imageWidth
    isHeighter = @state.data.get('imageHeight') > imageHeight
    isCover = isWidther and isHeighter

    url = constraint.thumbnail thumbnailUrl, imageHeight, imageWidth
    style = if url? then backgroundImage: "url(#{ url })" else {}

    div className: cx('preview', 'is-cover': isCover), style: style

  renderExtension: ->
    fileType = @state.data.get 'fileType'

    div className: 'extension',
      i className: 'icon icon-file'
      span {}, fileType

  render: ->
    cxView = cx 'file-view', 'is-clickable': @isFileClickable()

    onFileClick = =>
      if @isFileClickable()
        @props.onImageClick()

    form className: cx('form-table', 'is-dashed': not @state.isUploaded), onSubmit: @onFormSubmit,
      if @state.isUploaded
        div className: cxView, onClick: onFileClick,
          if @state.data.get('fileCategory').length is 0
            noscript()
          else if detect.isImageWithPreview(@state.data)
            @renderPreview()
          else
            @renderExtension()
          span className: 'btn-group',
            if not @props.readOnly
              a className: 'btn btn-delete', onClick: @handleFileDelete,
                Icon size: 18, name: 'trash'
            else noscript()

            # Disable file preview for a while.
            # if @props.displayMode isnt 'create'
              # a className: 'btn btn-view', onClick: @handleFileView,
                # Icon size: 18, name: 'search'
            # else noscript()
      else noscript()
      fieldset {},
        if not @state.isUploaded
          Uploader
            data: @state.data
            onComplete: @handleFileComplete
        else noscript()
        div className: 'form-row', hidden: not @state.isUploaded,
          input
            type: 'text'
            value: @state.data.get('fileName') or ''
            onChange: @handleFileNameChange
            readOnly: @props.readOnly
            autoFocus: not @props.readOnly
            className: 'text-row font-large text-overflow'
            placeholder: if not @props.readOnly then lang.getText 'placeholder-enter-filename'
        div className: 'form-row', hidden: not @state.isUploaded,
          Textarea
            value: @state.data.get('text') or ''
            onChange: @handleTextChange
            readOnly: @props.readOnly
            className: 'textarea-row font-normal'
            placeholder: if not @props.readOnly then lang.getText 'placeholder-enter-desc'
