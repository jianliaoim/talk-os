cx = require 'classnames'
hljs = require 'highlight.js/lib/highlight'
React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

code = React.createFactory 'code'
div = React.createFactory 'div'
pre = React.createFactory 'pre'

T = React.PropTypes

hljs.configure tabReplace: '  '
lengthLimit = 100 * 1000

module.exports = React.createClass
  displayName: 'lite-code-viewer'
  mixins: [PureRenderMixin]

  propTypes:
    codeType: T.string
    name: T.string
    text: T.string

  getDefaultProps: ->
    codeType: 'nohighlight'
    text: ''

  renderCode: ->
    hljs.highlightAuto(@props.text, [@props.codeType]).value

  render: ->
    className = cx
      'lite-code-viewer': true
      "is-for-#{ @props.name }": @props.name?

    div className: className, ref: 'viewer',
      pre null,
        if @props.text.length > lengthLimit
          code className: @props.codeType, @props.text
        else
          code
            className: @props.codeType
            dangerouslySetInnerHTML: __html: @renderCode()
