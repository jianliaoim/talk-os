React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ViewerFooter = React.createFactory require './viewer-footer'

lang = require '../locales/lang'

{div, span} = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'post-viewer'
  mixins: [PureRenderMixin]

  propTypes:
    isFavorite: T.bool
    canEdit: T.bool
    message: T.instanceOf(Immutable.Map)

  getDefaultProps: ->
    canEdit: true
    isFavorite:  false

  onClose: ->
    @props.onClose()

  render: ->
    return unless @props.message.get('attachments').get(0).get('category') is 'rtf'

    message = @props.message
    rtf = message.getIn(['attachments', 0, 'data'])
    html =
      __html: rtf.get('text') or ''

    div className: 'post-viewer',
      div className: 'header',
        div className: 'category line',
          lang.getText('category-post')
          span className: 'icon icon-remove', onClick: @onClose
        div className: 'title',
          span null, rtf.get('title')
      div className: 'content content-area rich-text editor-style', dangerouslySetInnerHTML: html
      ViewerFooter @props
