React = require 'react'
lang = require '../locales/lang'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div  = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'unread-divider'
  mixins: [PureRenderMixin]

  # no props yet

  render: ->

    div className: 'unread-divider flex-horiz flex-vcenter',
      div className: 'divider flex-fill'
      span className: 'hint', lang.getText('last-read-here')
