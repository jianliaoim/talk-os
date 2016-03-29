
React = require 'react'
Immutable = require 'immutable'

detect = require '../util/detect'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'

{div, input, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'succeed-resetting'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getAccount: ->
    @props.store.getIn(['client', 'account'])

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  render: ->
    div className: 'succeed-resetting control-panel',
      div className: 'as-line-centered',
        span className: 'hint', locales.get('resettedAndSigningIn', @getLanguage())
        Space width: 5
        @getAccount()
