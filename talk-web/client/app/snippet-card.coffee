React = require 'react'

LiteCodeViewer = React.createFactory require 'react-lite-coder/lib/code-viewer'

snippetUtil = require '../util/snippet'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'snippet-card'
  mixins: [ PureRenderMixin ]

  propTypes:
    text: T.string
    title: T.string
    onClick: T.func
    codeType: T.string

  getDefaultProps: ->
    codeType: 'txt'
    text: ''
    title: ''

  onClick: (event) ->
    event.stopPropagation()
    @props.onClick? event

  render: ->
    div className: 'snippet-card', onClick: @onClick,
      if @props.title.length then div className: 'title', @props.title else null
      LiteCodeViewer
        name: 'snippet-card'
        text: @props.text
        codeType: snippetUtil.getHighlightJS @props.codeType
