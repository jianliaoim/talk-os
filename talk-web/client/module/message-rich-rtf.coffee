React = require 'react'

detect = require '../util/detect'
format = require '../util/format'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-form-rtf'

  propTypes:
    onClick:    T.func
    attachment: T.object.isRequired

  onClick: (event) ->
    event.stopPropagation()
    @props.onClick?()

  renderTitle: ->
    if @props.attachment.data.title?.length
      div className: 'title', @props.attachment.data.title

  renderContent: ->
    return if not @props.attachment.data.text?.length
    text = format.parseRTF(@props.attachment.data.text)
    return if not text.length
    div className: 'content editor-style', dangerouslySetInnerHTML: __html: text

  renderPicture: ->
    includeImage = detect.imageUrlInHtml @props.attachment.data.text
    return if not includeImage
    style =
      backgroundImage: "url( #{ includeImage } )"
    div className: 'picture', style: style

  render: ->
    div className: 'attachment-rtf', onClick: @onClick,
      @renderTitle()
      @renderContent()
      @renderPicture()
