React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div  = React.createFactory 'div'
span = React.createFactory 'span'
lang = require '../locales/lang'

module.exports = React.createClass
  displayName: 'no-result'
  mixins: [PureRenderMixin]

  render: ->
    div className: 'no-result no-favorite',
      span className: "ti ti-alert-solid"
      div className: "message", lang.getText('no-results')
      div className: 'tip', lang.getText('no-results-need-keywords')
