cx = require 'classnames'
React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

mixinLayered = require '../mixin/layered'

Transition = React.createFactory require('react-lite-layered').Transition

a = React.createFactory 'a'
div = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'lite-new-modal'
  mixins: [mixinLayered]

  propTypes:
    show: T.bool.isRequired
    showClose: T.bool
    onCloseClick: T.func.isRequired
    name: T.string
    state: T.string
    title: T.string

  onBackdropClick: (event) ->
    event.stopPropagation()
    if not @props.showClose && event.target is event.currentTarget
      @onCloseClick()

  onCloseClick: ->
    @props.onCloseClick()

  renderLayer: (afterTransition) ->
    className = cx
      'lite-new-modal': true
      "is-for-#{ @props.name }": @props.name?
      "is-#{ @props.state }": @props.state?

    Transition transitionName: 'fade', enterTimeout: 200, leaveTimeout: 350,
      if @props.show and afterTransition
        div className: className, onClick: @onBackdropClick,
          div className: 'wrapper', onClick: @onBackdropClick,
            div className: 'box',
              div className: 'header',
                span {}, @props.title
                span className: 'icon icon-remove to-close', onClick: @onCloseClick
              div className: 'content',
                @props.children

  render: ->
    div()
