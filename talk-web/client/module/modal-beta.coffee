cx = require 'classnames'
React = require 'react'
keycode = require 'keycode'

mixinLayered = require '../mixin/layered'

Transition = React.createFactory require './transition'

{ a, div, span, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'lite-modal'
  mixins: [mixinLayered]

  propTypes:
    name: T.string
    show: T.bool.isRequired
    title: T.string
    onCloseClick: T.func.isRequired
    showCornerClose: T.bool

  bindWindowEvents: ->
    window.addEventListener 'keydown', @onWindowKeydown

  unbindWindowEvents: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  onWindowKeydown: (event) ->
    if keycode(event.keyCode) is 'esc'
      @onCloseClick()

  onCloseClick: ->
    @props.onCloseClick()

  onBackdropClick: (event) ->
    event.stopPropagation()
    if not @props.showCornerClose && event.target is event.currentTarget
      @onCloseClick()

  renderLayer: (afterTransition) ->
    className = cx 'lite-modal', "is-#{@props.name}"

    Transition transitionName: 'fade', enterTimeout: 300, leaveTimeout: 300,
      if @props.show and afterTransition
        div className: className, onClick: @onBackdropClick,
          div className: 'wrapper', onClick: @onBackdropClick,
            div className: 'box',
              if @props.title?
                div className: 'title',
                  span className: 'name', @props.title
                  span className: 'icon icon-remove', onClick: @onCloseClick
              @props.children

  render: ->
    noscript()
