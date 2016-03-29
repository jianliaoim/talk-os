React = require 'react'

mixinLayered = require '../mixin/layered'

Transition = React.createFactory require './transition'

{ div, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'fullscreen'
  mixins: [ mixinLayered ]

  propTypes:
    show: T.bool.isRequired

  renderLayer: (afterTransition) ->
    Transition transitionName: 'fade', enterTimeout: 300, leaveTimeout: 300,
      if @props.show and afterTransition
        div className: 'fullscreen',
          @props.children

  render: ->
    noscript()
