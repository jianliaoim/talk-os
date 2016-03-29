
React = require 'react'

lang = require '../locales/lang'
url =  require '../util/url'
handlers = require '../handlers'

{ div, p, a } = React.DOM

module.exports = React.createClass
  displayName: 'not-found'

  onBack: (event) ->
    event.preventDefault()
    handlers.routerHome()

  render: ->
    div className: 'not-found',
      div className: 'not-found-wrapper flex-vert flex-vcenter',
        div className: 'not-found-background background-contain'
        p className: 'not-found-tip', lang.getText('not-found-tip')
        div className: 'links',
          a onClick: @onBack,  lang.getText('return-to-app')
          a href: url.feedbackUrl, target: '_blank', lang.getText('contact-us')
