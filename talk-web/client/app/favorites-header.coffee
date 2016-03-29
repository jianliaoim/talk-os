React = require 'react'
debounce = require 'debounce'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div   = React.createFactory 'div'
span  = React.createFactory 'span'
input = React.createFactory 'input'

lang = require '../locales/lang'

detect = require '../util/detect'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'favorites-header'
  mixins: [PureRenderMixin]

  propTypes:
    onChange: T.func

  componentWillMount: ->
    @debouncedChange = debounce @onChange, 600

  onChange: ->
    value = @refs.input.value
    @props.onChange value

  render: ->
    div className: 'search-header favorites-header',
      div className: 'form-control',
        input
          ref: 'input'
          className: 'input'
          placeholder: lang.getText('search-with-keywords')
          onChange: @debouncedChange
          autoFocus: not detect.isIPad()
        span className: 'icon icon-search'
