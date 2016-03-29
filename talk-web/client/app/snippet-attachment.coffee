xss = require 'xss'
React = require 'react'

LiteCodeViewer = React.createFactory require 'react-lite-coder/lib/code-viewer'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'snippet-attachment'

  propTypes:
    getCodeType: T.func
    onClick:     T.func
    attachment:  T.object.isRequired

  onClick: (event) ->
    event.stopPropagation()
    @props.onClick?()

  renderTitle: ->
    return null if not @props.attachment.data.title?.length
    div className: 'title', @props.attachment.data.title

  renderContent: ->
    if @props.getCodeType?
      codeType = @props.getCodeType @props.attachment.data.codeType
    else if @props.attachment.data.codeType?.length
      codeType = @props.attachment.data.codeType
    else
      codeType = 'nohighlight'
    text = @props.attachment.data.text

    div className: 'content',
      LiteCodeViewer
        name: 'attachment-snippet'
        codeType: codeType,
        text: text

  render: ->
    div className: 'attachment-snippet', onClick: @onClick,
      @renderTitle()
      @renderContent()
