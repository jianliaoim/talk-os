React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ViewerFooter = React.createFactory require './viewer-footer'
CodeViewer = React.createFactory require '../module/code-viewer'

Icon = React.createFactory require '../module/icon'

snippetUtil = require '../util/snippet'
lang = require '../locales/lang'

{ div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'snippet-viewer'
  mixins: [ PureRenderMixin ]

  propTypes:
    canEdit: T.bool
    isFavorite: T.bool
    onClose: T.func.isRequired
    message: T.object.isRequired

  getDefaultProps: ->
    canEdit: true
    isFavorite: false

  onClose: ->
    @props.onClose?()

  render: ->
    return null if not @props.message.get('attachments').size

    target = @props.message.get('attachments').filter (attachment) ->
      attachment.get('category') is 'snippet'

    return null if not target.size

    data = target.get(0).get 'data'

    div className: 'snippet-viewer',
      div className: 'header',
        div className: 'category line flex-horiz flex-vcenter',
          Icon name: 'pre', size: 20
          lang.getText('category-snippet')
        Icon name: 'remove', className: 'button-close', size: 20, onClick: @onClose
      div className: 'body',
        div className: 'info',
          div className: 'title', data.get 'title'
          div className: 'type', snippetUtil.getName data.get 'codeType'
        CodeViewer
          name: 'snippet-viewer'
          text: data.get 'text'
          codeType: snippetUtil.getHighlightJS data.get 'codeType'
      ViewerFooter @props
