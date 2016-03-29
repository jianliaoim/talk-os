React   = require 'react'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

detect  = require '../util/detect'

div   = React.createFactory 'div'
span   = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'user-alias'

  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    defaultName: T.string.isRequired
    replaceMe: T.bool
    onClick: T.func

  getDefaultProps: ->
    replaceMe: false

  getInitialState: ->
    alias: @getAlias()

  componentDidMount: ->
    @subscribe recorder, => @setState alias: @getAlias()

  getAlias: ->
    prefs = query.contactPrefsBy(recorder.getState(), @props._teamId, @props._userId)
    alias = prefs?.get('alias')

  onClick: (event) ->
    @props.onClick?(event)

  render: ->
    contact = query.requestContactsByOne(recorder.getState(), @props._teamId, @props._userId)
    myId = query.userId(recorder.getState())
    if @props.replaceMe and @props._userId is myId
      name = lang.getText('me')
    else if contact? and detect.isTalkai(contact)
      name = lang.getText('ai-robot')
    else
      name = @state.alias or @props.defaultName or lang.getText('someone')

    span className: 'name text-overflow', onClick: @onClick, name
