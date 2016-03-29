React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

{div, svg, path} = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'container-wireframe'

  mixins: [ PureRenderMixin ]

  propTypes:
    sentence: T.string.isRequired

  render: ->
    div className: 'app-view',
      div className: 'app-loading',
        # https://github.com/jianliaoim/talk-logo/tree/master
        svg
          width: '80'
          height: '80'
          viewBox: '0 0 120 120'
          path
            className: 'path'
            d: 'M 40 40 L 60 40 A 20 20 0 1 1 40 60 L 40 8 L 60 8 A 52 52 0 1 1 31.5 103.8 L 8 112 L 16 86 A 52 52 0 0 1 8 60 L 8 40 Z'
        div id: 'precept', className: 'precept', @props.sentence
