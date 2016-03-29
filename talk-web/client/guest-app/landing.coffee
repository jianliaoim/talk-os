React = require 'react'

lang = require '../locales/lang'

div  = React.createFactory 'div'

module.exports = React.createClass

  displayName: 'app-loading'

  render: ->
    div id: 'app-view',
      div className: 'app-loading',
        div className: 'talk-logo'
        div className: 'muted', lang.getText('landing-app')
