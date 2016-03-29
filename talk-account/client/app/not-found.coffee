

React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'

{div, input, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'not-found'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  render: ->
    siteUrl = @props.store.getIn ['client', 'siteUrl']

    div className: 'not-found control-panel',
      div className: 'as-line',
        span className: 'hint-error', locales.get('pageNotFound', @getLanguage())
      Space height: 15
      div className: 'as-line-centered',
        a href: "#{siteUrl}", locales.get('backToApp', @getLanguage())
