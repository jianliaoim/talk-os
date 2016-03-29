cx = require 'classnames'
React = require 'react'
keycode = require 'keycode'

lang = require '../locales/lang'

LiteModalBeta = React.createFactory require '../module/modal-beta'

{ a, div, span, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'slim-modal'

  propTypes:
    show: T.bool.isRequired
    title: T.string
    description: T.string
    color: T.oneOf(['green', 'red'])
    onBack: T.func
    extra: T.node
    onClose: T.func.isRequired

  getDefaultProps: ->
    color: 'red'

  renderHeader: ->
    div className: 'slim-modal-header flex-static',
      div className: 'navbar',
        if @props.onBack?
          div className: 'nav-left',
            div className: 'button is-link', onClick: @props.onBack,
              span className: 'icon icon-arrow-left'
              lang.getText('return')
        else
          div className: 'nav-left',
            if @props.title?
              span className: 'title', @props.title
            if @props.description?
              span className: 'description muted', @props.description
        div className: 'nav-right',
          @props.extra

  render: ->
    cxBody = cx 'slim-modal-body', 'flex-fill', "color-#{ @props.color }"

    LiteModalBeta
      name: 'slim-modal'
      show: @props.show
      onCloseClick: @props.onClose
      div className: 'slim-modal flex-vert',
        @renderHeader()
        div className: cxBody,
          @props.children
