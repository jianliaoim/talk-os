React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

eventBus = require '../event-bus'

T = React.PropTypes
span = React.createFactory 'span'

module.exports = React.createClass
  displayName: 'file-glance'
  mixins: [PureRenderMixin]

  propTypes:
    file: T.instanceOf(Immutable.Map)
    onClick: T.func.isRequired
    progress: T.number

  isLocal: ->
    # no fileKey before uploaded to server
    not @props.file.get('fileKey')?

  onClick: ->
    @props.onClick()

  renderProgress: ->
    if @isLocal() and @props.progress?
      span className: 'muted percentage',
        " (#{(@props.progress * 100).toFixed()}%)"

  render: ->
    span className: 'file-glance',
      span className: 'filename', onClick: @onClick, @props.file.get('fileName')
      @renderProgress()
