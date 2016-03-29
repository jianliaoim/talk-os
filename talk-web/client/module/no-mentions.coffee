React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

{ div, span } = React.DOM

module.exports = React.createClass
  displayName: 'no-mentions'
  mixins: [PureRenderMixin]

  render: ->
    div className: 'no-mentions',
      span className: 'icon icon-at'
      div className: 'message', lang.getText 'no-mentions'
