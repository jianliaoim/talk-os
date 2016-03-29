React = require 'react'

lang = require '../locales/lang'

{div, pre, span, a} = React.DOM
correctExample = 'https://jianliao.com/rooms/<room_token>'

module.exports = React.createClass
  displayName: 'app-missing'

  render: ->
    div className: 'app-missing',
      div className: 'as-guide',
        div className: 'as-icon'
        span className: 'as-status-code', 404
      div className: 'as-note',
        div null, lang.getText('room-missing')
        div null,
          lang.getText('correct-guest-url')
          a className: 'as-url', correctExample
