
React = require 'react'
Immutable = require 'immutable'

detect = require '../util/detect'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'

{div, input, span, a} = React.DOM

# without window.opener, JavaScript is not able to close a window
isThereAnOpener = switch
  when typeof window is 'undefined' then false
  when window.opener? then true
  else false

module.exports = React.createClass
  displayName: 'succeed-binding'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getAccount: ->
    @props.store.getIn(['client', 'account'])

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  render: ->
    guideText = switch
      when isThereAnOpener
        locales.get('boundAndClosing', @getLanguage())
      else
        locales.get('boundAndCloseManually', @getLanguage())

    div className: 'succeed-binding control-panel',
      div className: 'as-line-centered',
        span className: 'hint', guideText
