React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

div   = React.createFactory 'div'
audio = React.createFactory 'audio'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'file-audio'
  mixins: [PureRenderMixin]

  propTypes:
    file: T.instanceOf(Immutable.Map)

  render: ->
    src = @props.file.get('downloadUrl')

    div className: 'file-audio',
      audio src: src, controls: true, autoPlay: true,
        l('html5AudioNotSupport')
