React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

div   = React.createFactory 'div'
video = React.createFactory 'video'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'file-video'
  mixins: [PureRenderMixin]

  propTypes:
    file: T.instanceOf(Immutable.Map)

  render: ->
    src = @props.file.get('downloadUrl')

    div className: 'file-video',
      video src: src, controls: true, autoPlay: true,
        l('html5VideoNotSupport')
