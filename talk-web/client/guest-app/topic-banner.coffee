React = require 'react'

lang = require '../locales/lang'
dispatcher = require '../dispatcher'

h2  = React.createFactory 'h2'
div = React.createFactory 'div'
a   = React.createFactory 'a'

module.exports = React.createClass
  displayName: 'topic-banner'

  propsTypes:
    showEmailHint: React.PropTypes.bool.isRequired

  # renderers

  render: ->

    [before, after] = lang.getText('about-guest-email').split('%s')

    div className: 'topic-banner',
      h2 {}, lang.getText('welcome-to-talk')
      div {}, lang.getText('about-guest-talk')
