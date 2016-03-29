cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'

lang = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

detect  = require '../util/detect'

{ div } = React.DOM

module.exports = React.createClass
  displayName: 'contact-banner'

  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    data: React.PropTypes.object.isRequired

  getInitialState: ->
    displayMode: @getDisplayMode()
    alias: @getAlias()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        displayMode: @getDisplayMode()
        alias: @getAlias()

  getDisplayMode: ->
    query.prefs(recorder.getState())?.get('displayMode') or 'default'

  getAlias: ->
    alias = query.contactPrefsBy(recorder.getState(), @props._teamId, @props.data.get('_id'))?.get('alias')

  render: ->
    if detect.isTalkai(@props.data)
      name = lang.getText('ai-robot')
      note = lang.getText('robot-welcome-note')
    else
      name = @props.data.get('name')
      note = lang.getText('room-main-contact')

    displayModeClass = cx
      'display-default': (@state.displayMode is 'default')
      'display-slim': (@state.displayMode isnt 'default')

    div className: 'contact-banner',
      div className: displayModeClass,
        if @state.displayMode is 'default'
          div
            className: 'avatar img-circle img-60'
            style:
              backgroundImage: "url('#{@props.data.get('avatarUrl')}')"
        div className: 'box',
          div className: 'name', @getAlias() or name
          div className: 'about', note
