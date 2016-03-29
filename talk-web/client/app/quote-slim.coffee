React = require 'react'
Immutable = require 'immutable'

format = require '../util/format'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'quote-slim'

  propTypes:
    quote: T.instanceOf(Immutable.Map)
    onClick: T.func.isRequired

  onClick: ->
    @props.onClick @props.quote.get('redirectUrl')

  render: ->
    wholeText = format.htmlAsText(@props.quote.get('text') or '')
    if wholeText.length > 200
      visibleText = "#{wholeText[...200]}..."
    else
      visibleText = wholeText

    div className: 'quote-slim', onClick: @onClick,
      div className: 'title',
        @props.quote.get('title')
      div className: 'body', visibleText
