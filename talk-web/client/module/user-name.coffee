cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'user-name'
  mixins: [ mixinSubscribe, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    isRobot: T.bool
    name: T.string
    service: T.string
    className: T.string
    component: T.any

  getDefaultProps: ->
    component: 'span'

  getInitialState: ->
    prefs: @getPrefs()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        prefs: @getPrefs()

  getPrefs: ->
    store = recorder.getState()
    _teamId = @props._teamId
    _userId = @props._userId

    query.contactPrefsBy store, _teamId, _userId

  render: ->
    { name, isRobot, service } = @props
    prefs = @state.prefs
    alias = prefs?.get 'alias'

    if alias?.trim()
      name = alias
    if isRobot and service is 'talkai'
      name = lang.getText 'ai-robot'

    React.createElement @props.component,
      className: cx(@props.className)
      name
