React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

colors = require '../util/colors'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-default'
  mixins: [PureRenderMixin]

  propTypes:
    file: T.instanceOf(Immutable.Map)

  render: ->
    extname = @props.file.get('fileType')
    bgStyle =
      backgroundColor: colors.files[extname] or colors.files['file']

    div className: 'file-default',
      div className: 'display short', style: bgStyle, extname
