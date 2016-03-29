xss = require 'xss'
React = require 'react'
cx = require 'classnames'
filesize = require 'filesize'

position = require '../util/file-type'
Icon = React.createFactory require './icon'

{ div, span, a, i } = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-rich-file'

  propTypes:
    onClick: T.func
    attachment: T.object.isRequired
    color: T.string

  getColor: ->
    if @props.color?.length
      color = @props.color
    else
      color = '#7986CB'

  onClick: (event) ->
    event.stopPropagation()
    unless @props.attachment.isUploading?
      @props.onClick?()

  onDownloadClick: (event) ->
    event.stopPropagation()

  renderFileType: ->
    style =
      backgroundPosition: position.get(@props.attachment.data)
    div className: 'file-type', style: style

  renderFileName: ->
    return if not @props.attachment.data.fileName?
    fileName = if @props.attachment.data.fileName.length then @props.attachment.data.fileName else '?'
    div className: 'file-name',
      span dangerouslySetInnerHTML: __html: xss fileName

  renderFileSize: ->
    return if not @props.attachment.data.fileSize?
    span className: 'file-size', filesize @props.attachment.data.fileSize, unix: true

  renderFileDetails: ->
    div className: 'file-details',
      @renderFileName()
      @renderFileSize()

  renderActions: ->
    unless @props.attachment.isUploading?
      a
        className: 'action'
        href: @props.attachment.data.downloadUrl
        onClick: @onDownloadClick
        Icon name: 'download-solid', size: 18

  render: ->
    className = cx 'attachment-file', 'is-clickable': not @props.attachment.isUploading?
    div className: className, onClick: @onClick,
      @renderFileType()
      @renderFileDetails()
      @renderActions()
