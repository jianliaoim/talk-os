React = require 'react'

PureRenderMixin = require 'react-addons-pure-render-mixin'
T = React.PropTypes

addedEvents = []

KEY_EVENT = 'keydown'

module.exports = React.createClass
  displayName: 'keyboard'
  mixins: [ PureRenderMixin ]

  propTypes:
    isRegistered: T.bool.isRequired
    onTrigger: T.func.isRequired
    onRegister: T.func
    onUnregister: T.func

  getDefaultProps: ->
    onRegister: (->)
    onUnregister: (->)

  getInitialState: ->
    isFocused: false

  componentDidMount: ->
    @shouldRegisterEvent @props.isRegistered

  componentWillReceiveProps: (nextProps) ->
    @shouldRegisterEvent nextProps.isRegistered

  shouldRegisterEvent: (isRegistered) ->
    if isRegistered
      if not @props.isRegistered
        @props.onRegister()
        window.addEventListener KEY_EVENT, @handleKeyEvent
    else
      @props.onUnregister()
      window.removeEventListener KEY_EVENT, @handleKeyEvent

  handleKeyEvent: (event) ->
    @props.onTrigger event

  render: ->
    null
