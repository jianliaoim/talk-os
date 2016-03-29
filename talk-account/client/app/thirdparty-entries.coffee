
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'

{div, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'thirdparty-entries'

  propTypes:
    language: React.PropTypes.string.isRequired

  onRedirectTeambition: (event) ->
    event.preventDefault()
    controllers.redirectThirdPartyAuth '/union/teambition'

  render: ->
    a
      className: 'thirdparty-entries', href: '/union/teambition'
      onClick: @onRedirectTeambition
      span className: 'teambition-icon icon icon-t'
      Space width: 10
      span 'guide-text', locales.get('signInWithTeambition', @props.language)
