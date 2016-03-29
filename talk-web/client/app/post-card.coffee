React = require 'react'
classnames = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

detect  = require '../util/detect'
format  = require '../util/format'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'post-card'
  mixins: [PureRenderMixin]

  propTypes:
    text: T.string.isRequired
    onClick: T.func

  onClick: (event) ->
    event.stopPropagation()
    @props.onClick?()

  render: ->
    maybeImage = detect.imageUrlInHtml @props.text
    html = format.htmlAsText(@props.text).replace(/\n+/g, ' ')
    boxClass = classnames
      'post-box': true
      'is-with-image': maybeImage?
    imageStyle =
      backgroundImage: "url(#{maybeImage or ''})"

    div className: 'post-card', onClick: @onClick,
      if maybeImage?
        div className: 'post-image', src: maybeImage[0], style: imageStyle
      div className: boxClass,
        if html.trim().length > 0
          div className: 'post-text', html
