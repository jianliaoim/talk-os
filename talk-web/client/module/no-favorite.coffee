React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div  = React.createFactory 'div'
span = React.createFactory 'span'
lang = require '../locales/lang'

module.exports = React.createClass
  displayName: 'no-favorite'
  mixins: [PureRenderMixin]

  render: ->
    div className: 'no-favorite',
      span className: "icon icon-star"
      div className: "message", lang.getText('no-favorite')
      div className: 'tip', lang.getText('no-favorite-tip')
