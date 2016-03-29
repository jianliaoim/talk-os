
React = require 'react'
keycode = require 'keycode'
Immutable = require 'immutable'

routes = require '../routes'
locales = require '../locales'
controllers = require '../controllers'

Brand = React.createFactory require './brand'
Space = React.createFactory require 'react-lite-space'
Signin = React.createFactory require './signin'
Signup = React.createFactory require './signup'
Accounts = React.createFactory require './accounts'
DevTools = React.createFactory require 'actions-recorder/lib/devtools'
NotFound = React.createFactory require './not-found'
BindEmail = React.createFactory require './bind-email'
EmailSent = React.createFactory require './email-sent'
BindMobile = React.createFactory require './bind-mobile'
Addressbar = React.createFactory require 'router-view'
VerifyEmail = React.createFactory require './verify-email'
SucceedBinding = React.createFactory require './succeed-binding'
BindThirdparty = React.createFactory require './bind-thirdparty'
ForgotPassword = React.createFactory require './forgot-password'
SucceedResetting = React.createFactory require './succeed-resetting'
EmailResetPassword = React.createFactory require './email-reset-password'

{div, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'app-page'
  propTypes:
    core: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showDevTools: false
    path: Immutable.List()

  componentDidMount: ->
    window.addEventListener 'keydown', @onWindowKeydown

  componentWillUnount: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  getLanguage: ->
    store = @props.core.get('store')
    store.getIn(['client', 'language'])

  onWindowKeydown: (event) ->
    if (keycode event.keyCode) is 'a' and event.shiftKey and (event.metaKey or event.ctrlKey)
      @setState showDevTools: (not @state.showDevTools)

  onPathChange: (newPath) ->
    @setState path: newPath

  onPopstate: (info, event) ->
    controllers.routeGo info

  onBackToApp: ->
    controllers.signInRedirect()

  renderError: ->
    store = @props.core.get('store')
    div className: 'server-error control-panel',
      div className: 'as-line-centered',
        span className: 'hint-error', store.getIn(['serverError', 'message'])
      Space height: 40
      div className: 'as-line-centered',
        a onClick: @onBackToApp, locales.get('backToApp', @getLanguage())

  renderPage: ->
    store = @props.core.get('store')
    router = store.get('router')

    switch router.get('name')
      when 'signin' then Signin store: store
      when 'signup' then Signup store: store
      when 'forgot-password' then ForgotPassword store: store
      when 'email-sent' then EmailSent store: store
      when 'reset-password' then EmailResetPassword store: store
      when 'succeed-resetting' then SucceedResetting store: store
      when 'bind-mobile' then BindMobile store: store
      when 'bind-thirdparty' then BindThirdparty store: store
      when 'bind-email' then BindEmail store: store
      when 'verify-email' then VerifyEmail store: store
      when 'succeed-binding' then SucceedBinding store: store
      when 'accounts' then Accounts store: store
      when '404' then NotFound store: store

  renderAddressbar: ->
    Addressbar
      route: @props.core.getIn ['store', 'router']
      rules: routes
      onPopstate: @onPopstate
      skipRendering: false

  renderDevTools: ->
    div className: 'devtools-layer',
      DevTools
        core: @props.core, width: innerWidth, height: innerHeight
        path: @state.path, onPathChange: @onPathChange

  renderFeature: ->
    div className: 'app-feature',
      div className: 'brand-cover'
      Brand language: @getLanguage()

  render: ->
    store = @props.core.get('store')

    div className: 'app-page',
      div className: 'main-card',
        @renderFeature()
        div className: 'app-container',
          if store.get('serverError')?
            @renderError()
          else
            @renderPage()
      @renderAddressbar()
      if @state.showDevTools
        @renderDevTools()
