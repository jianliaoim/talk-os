React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang  = require '../locales/lang'

time = require '../util/time'
clock = require '../util/clock'
shortid = require 'shortid'

span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'relative-time'
  mixins: [PureRenderMixin]

  propTypes:
    data: T.string.isRequired
    edited: T.string # not edited

  getInitialState: ->
    now: (new Date).toISOString()
    clockId: shortid.generate()

  componentDidMount: ->
    clock.add @state.clockId, @setNow

  componentWillUnmount: ->
    clock.remove @state.clockId

  setNow: ->
    @setState now: (new Date).toISOString()

  render: ->
    text = time.calendar @props.data
    if @props.edited? and time.isMessageEdited(@props.data, @props.edited)
      editedTime = time.calendar @props.edited
      template = lang.getText('created-updated-time')
      text = template
      .replace '{{created}}', text
      .replace '{{updated}}', editedTime

    span className: 'relative-time muted',
      text
