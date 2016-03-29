
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
detect = require '../util/detect'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
MobileInput = React.createFactory require './mobile-input'
CaptchaIcons = React.createFactory require './captcha-icons'
VerifyMobile = React.createFactory require './verify-mobile'
ForceBindMobile = React.createFactory require './forcebind-mobile'

{div, input, form, button, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'bind-mobile'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    randomCode: ''
    showVerifyMobile: false
    bindCode: null
    showForceBind: false
    error: null
    captchaUid: null

  getAccount: ->
    @props.store.getIn(['client', 'account'])

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  isChangingBinding: ->
    # /bind-mobile?action=change
    @props.store.getIn(['router', 'query', 'action']) is 'change'

  onAccountChange: (account) ->
    @setState error: null
    controllers.updateAccount account

  onSendVerifyCode: ->
    if detect.isMobile(@getAccount())
      if @state.captchaUid?
        ajax.mobileSendVerifyCode
          data:
            phoneNumber: @getAccount()
            action: 'bind'
            uid: @state.captchaUid
          success: (resp) =>
            @setState error: null, randomCode: resp.randomCode, showVerifyMobile: true
          error: (err) =>
            error = JSON.parse err.response
            @setState error: error.message
      else
        @setState error: locales.get('captchaIsRequired', @getLanguage())
    else
      @setState error: locales.get('unknownAccountType', @getLanguage())

  onMobileVerify: (verifyCode) ->
    if @isChangingBinding()
      @onMobileChange verifyCode
    else
      @onMobileBind verifyCode

  onMobileBind: (verifyCode) ->
    ajax.mobileBind
      data:
        randomCode: @state.randomCode
        verifyCode: verifyCode
      success: (resp) =>
        controllers.signInRedirect()
        @setState error: null
      error: (err) =>
        error = JSON.parse err.response
        if error.code is 230 # number is already bound
          @setState
            bindCode: error.data.bindCode
            showForceBind: true
        else
          @setState error: error.message

  onMobileChange: (verifyCode) ->
    ajax.mobileChange
      data:
        randomCode: @state.randomCode
        verifyCode: verifyCode
      success: (resp) =>
        controllers.signInRedirect()
        @setState error: null
      error: (err) =>
        error = JSON.parse err.response
        if error.code is 230 # number is already bound
          @setState
            bindCode: error.data.bindCode
            showForceBind: true
        else
          @setState error: error.message

  onBack: ->
    @setState showVerifyMobile: false

  onSubmit: (event) ->
    event.preventDefault()
    @onSendVerifyCode()

  onCaptchaSelect: (uid) ->
    @setState captchaUid: uid

  renderVerifyMobile: ->
    VerifyMobile
      store: @props.store
      onResend: @onSendVerifyCode
      onVerify: @onMobileVerify
      onBack: @onBack
      isLoading: @isLoading()
      error: @state.error

  renderForceBind: ->
    ForceBindMobile
      bindCode: @state.bindCode
      language: @getLanguage()

  render: ->
    if @state.showForceBind
      return @renderForceBind()
    if @state.showVerifyMobile
      return @renderVerifyMobile()

    form className: 'bind-mobile control-panel', onSubmit: @onSubmit,
      div className: 'as-line-centered',
        if @isChangingBinding()
          span className: 'hint-title', locales.get('verifyToChangeMobile', @getLanguage())
        else
          span className: 'hint-title', locales.get('verifyToBindMobile', @getLanguage())
          Space height: 15
      MobileInput
        language: @getLanguage(), account: @getAccount()
        onChange: @onAccountChange
        autoFocus: true
      div className: 'as-block vbox',
        Space height: 15
        CaptchaIcons
          lang: @getLanguage(), onSelect: @onCaptchaSelect, isDone: @state.captchaUid?
      Space height: 20
      if @state.error?
        div className: 'as-line',
          span className: 'hint-error', @state.error
          Space height: 15
      if @isLoading()
        button className: 'button is-primary is-disabled',
          locales.get('bindPhone', @getLanguage())
      else
        button className: 'button is-primary',
          locales.get('bindPhone', @getLanguage())
