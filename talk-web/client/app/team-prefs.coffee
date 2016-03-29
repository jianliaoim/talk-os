React   = require 'react'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

query = require '../query'
lang = require '../locales/lang'

teamActions     = require '../actions/team'
notifyActions = require '../actions/notify'
contactPrefsActions = require '../actions/contact-prefs'

LightCheckbox = React.createFactory require '../module/light-checkbox'

mixinSubscribe = require '../mixin/subscribe'

div    = React.createFactory 'div'
button = React.createFactory 'button'
input  = React.createFactory 'input'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-prefs'

  propTypes:
    user:  T.object.isRequired
    team:  T.object.isRequired
    close: T.func.isRequired

  mixins: [LinkedStateMixin, mixinSubscribe, PureRenderMixin]

  getInitialState: ->
    alias: @getAlias()
    hideMobile: @getHideMobile()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState alias: @getAlias(), hideMobile: @getHideMobile()

  getAlias: ->
    prefs = query.contactPrefsBy(recorder.getState(), @props.team.get('_id'), @props.user.get('_id'))
    prefs?.get('alias') or ''

  getHideMobile: ->
    prefs = query.contactPrefsBy(recorder.getState(), @props.team.get('_id'), @props.user.get('_id'))
    prefs?.get('hideMobile') or false

  onHideMoblie: ->
    @setState hideMobile: not @state.hideMobile

  onSubmit: ->
    if @state.alias.trim().length < 30
      data =
        prefs:
          alias: @state.alias.trim(),
          hideMobile: @state.hideMobile

      contactPrefsActions.updateInTeam(@props.team.get('_id'), @props.user.get('_id'), data)
      @props.close()
    else
      notifyActions.warn lang.getText('invalid-length')

  render: ->
    div className: 'team-prefs',
      div className: 'bold', lang.getText('nickname')
      div className: 'muted', lang.getText('nickname-setting-tips')
      input type: 'text', className: 'form-control', placeholder: lang.getText('enter-nickname'), valueLink: @linkState('alias')
      div className: 'bold', lang.getText('contact-info')
      LightCheckbox
        checked: @state.hideMobile
        name:    lang.getText('hide-mobile-phone')
        onClick: @onHideMoblie
      button className: 'button is-primary', onClick: @onSubmit, lang.getText('save')
