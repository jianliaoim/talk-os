React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div  = React.createFactory 'div'
span = React.createFactory 'span'
lang = require '../locales/lang'

module.exports = React.createClass
  displayName: 'no-result'
  mixins: [PureRenderMixin]

  propTypes: {}

  render: ->
    div className: 'no-result no-favorite',
      span className: "icon icon-circle-warning"
      div className: "message", lang.getText('no-results')
      div className: 'tip', lang.getText('no-results-need-keywords')
