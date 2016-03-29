React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

detect = require '../util/detect'
format = require '../util/format'
colors = require '../util/colors'

mixinMessageHandler = require '../mixin/message-handler'

T = React.PropTypes

div = React.createFactory 'div'

module.exports = React.createClass
  displayName: 'msg-file'
  mixins: [mixinMessageHandler, PureRenderMixin]

  propTypes:
    attachment: T.instanceOf(Immutable.Map)
    onClick: T.func.isRequired

  onClick: (event) ->
    event.stopPropagation()
    @props.onClick @props.attachment

  render: ->
    file = @props.attachment.get('data')

    extname = file.get('fileType') or 'bin'

    textStyle =
      fontFamily: window.getComputedStyle?(document.body).fontFamily or 'serif'
      fontSize: 14

    fileName = file.get('fileName')

    unless detect.textWidthSmaller fileName, textStyle, 200, 20
      fileName = format.fileName fileName, 20

    div className: 'msg-file msg-collection', onClick: @onClick,
      if (file.get('fileCategory') is 'image') and file.get('thumbnailUrl')
        imgUrl = file.get('thumbnailUrl').replace(/\/200/g, '/800')
        imageStyle = backgroundImage: "url(#{imgUrl})"
        div className: 'preview', style: imageStyle
      else
        previewStyle =
          backgroundColor: colors.files[extname] or colors.files['file']
        div className: 'preview', style: previewStyle, extname[0]
      div className: 'text', fileName
