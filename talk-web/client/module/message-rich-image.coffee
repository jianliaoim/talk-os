React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

LightImage = React.createFactory require '../module/light-image'

{div, span} = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-rich-image'

  mixins: [ PureRenderMixin ]

  propTypes:
    # attachment = {
    #   data:
    #     thumbnailUrl: string
    #     imageHeight: number
    #     imageWidth: number
    #   isUploading: boolean
    #   progress: boolean
    # }
    attachment: T.instanceOf(Immutable.Map).isRequired
    widthBoundary: T.number
    heightBoundary: T.number
    onClick: T.func
    onLoaded: T.func

  getDefaultProps: ->
    widthBoundary: 360
    heightBoundary: 360

  onClick: ->
    @props.onClick?()

  onLoaded: ->
    @props.onLoaded?()

  renderPreview: ->
    thumbnailUrl = @props.attachment.getIn ['data', 'thumbnailUrl']
    imageHeight = @props.attachment.getIn ['data', 'imageHeight']
    imageWidth = @props.attachment.getIn ['data', 'imageWidth']

    insideX = imageWidth <= @props.widthBoundary
    insideY = imageHeight <= @props.heightBoundary

    if insideX and insideY
      previewWidth = imageWidth
      previewHeight = imageHeight
    else
      boundaryRatio = @props.widthBoundary / @props.heightBoundary
      realRatio = imageWidth / imageHeight

      if boundaryRatio > realRatio # boundary is wider, use height as base
        previewHeight = @props.heightBoundary
        previewWidth = Math.round(@props.heightBoundary / imageHeight * imageWidth)
      else
        previewWidth = @props.widthBoundary
        previewHeight = Math.round(@props.widthBoundary / imageWidth * imageHeight)

    src = # don't parse preview image if thumbnailUrl is a data uri generated from canvas.todataurl
      if thumbnailUrl.substring(0, 4) is 'data'
        thumbnailUrl
      else
        thumbnailUrl
          .replace(/(\/h\/\d+)/g, "/h/#{previewHeight}")
          .replace(/(\/w\/\d+)/g, "/w/#{previewWidth}")

    style =
      height: previewHeight
      maxWidth: previewWidth

    image = LightImage
      src: src
      onClick: @onClick
      onLoaded: @onLoaded
      width: previewWidth
      height: previewHeight

    div className: 'preview', style: style,
      image

  render: ->
    div className: 'attachment-image',
      @renderPreview()
