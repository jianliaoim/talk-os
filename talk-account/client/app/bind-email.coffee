
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
detect = require '../util/detect'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
ForceBindMobile = React.createFactory require './forcebind-mobile'

{div, button, form, input, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'bind-email'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    randomCode: ''
    showVerifyMobile: false
    bindCode: null
    showForceBind: false
    error: null

  getAccount: ->
    @props.store.getIn(['client', 'account'])

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  isChangingBinding: ->
    # /bind-mobile?action=change
    @props.store.getIn(['router', 'query', 'action']) is 'change'

  onAccountChange: (event) ->
    if detect.isQQEmail event.target.value
      error = locales.get 'warningAboutQQEmail', @getLanguage()

    @setState error: error or null
    controllers.updateAccount event.target.value

  onBack: ->
    @setState showVerifyMobile: false

  onSubmit: (event) ->
    event.preventDefault()
    @onSendVerifyEmail()

  onSendVerifyEmail: ->
    if detect.isEmail(@getAccount())
      ajax.emailSendVerifyCode
        data:
          emailAddress: @getAccount()
          action: if @isChangingBinding() then 'change' else 'bind'
        success: (resp) =>
          @setState error: null
          controllers.routeEmailSent()
        error: (err) =>
          error = JSON.parse err.response
          @setState error: error.message
    else
      @setState error: locales.get('unknownAccountType', @getLanguage())

  render: ->
    form className: 'bind-email control-panel', onSubmit: @onSubmit,
      div className: 'as-line-centered',
        if @isChangingBinding()
          span className: 'hint-title', locales.get('verifyToChangeEmail', @getLanguage())
        else
          span className: 'hint-title', locales.get('verifyToBindEmail', @getLanguage())
      Space height: 15
      div className: 'as-line-filled',
        input
          type: 'email', value: @getAccount(), onChange: @onAccountChange
          placeholder: locales.get('email', @getLanguage())
          autoFocus: true
        if detect.isEmail(@getAccount())
          span className: 'icon icon-tick ok-icon'
      Space height: 35
      if @state.error?
        div className: 'as-line',
          span className: 'hint-error', @state.error
          Space height: 15
      if @isLoading()
        button className: 'button is-primary is-disabled',
          locales.get('sendVerifyEmail', @getLanguage())
      else
        button className: 'button is-primary',
          locales.get('sendVerifyEmail', @getLanguage())
