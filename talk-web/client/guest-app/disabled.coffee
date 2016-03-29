React = require 'react'

lang = require '../locales/lang'

{div, span} = React.DOM

module.exports = React.createClass
  displayName: 'app-disabled'

  render: ->
    div className: 'app-disabled',
      div className: 'as-guide',
        div className: 'as-icon'
        span className: 'as-status-code', 404
      div className: 'as-note',
        lang.getText('room-disabled')
