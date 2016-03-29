
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
detect = require '../util/detect'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
MobileInput = React.createFactory require './mobile-input'
VerifyMobile = React.createFactory require './verify-mobile'
CaptchaIcons = React.createFactory require './captcha-icons'
AccountSwitcher = React.createFactory require './account-switcher'
ResetPassword = React.createFactory require './reset-password'

{div, button, form, input, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'forgot-password'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    account = @getAccount()

    tab: if (account[0] is '+') then 'mobile' else 'email'
    error: null
    randomCode: null
    showVerifyMobile: false
    showResetPassword: false
    captchaUid: null

  getAccount: ->
    @props.store.getIn(['client', 'account'])

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  onAccountChange: (event) ->
    if detect.isQQEmail event.target.value
      error = locales.get 'warningAboutQQEmail', @getLanguage()

    @setState error: error or null
    controllers.updateAccount event.target.value

  onMobileAccountChange: (account) ->
    @setState error: null
    controllers.updateAccount account

  onTabSwitch: (tab) ->
    @setState
      tab: tab
      error: null
      captchaUid: null
    if tab is 'email'
      controllers.updateAccount ''
    else
      controllers.updateAccount '+86'

  onNext: ->
    if @state.tab is 'email'
      if detect.isEmail @getAccount()
        @setState
          error: null
        ajax.emailSendVerifyCode
          data:
            emailAddress: @getAccount()
            action: 'resetpassword'
            uid: @state.captchaUid
          success: (resp) =>
            controllers.routeEmailSent()
            @setState error: null
          error: (err) =>
            error = JSON.parse err.response
            @setState error: error.message
      else
        @setState
          error: locales.get('notEmail', @getLanguage())
    else if @state.tab is 'mobile'
      if detect.isMobile @getAccount()
        @setState
          error: null
        ajax.mobileSendVerifyCode
          data:
            phoneNumber: @getAccount()
            action: 'resetpassword'
          success: (resp) =>
            @setState
              error: null
              randomCode: resp.randomCode
              showVerifyMobile: true
          error: (err) =>
            error = JSON.parse err.response
            @setState error: error.message
      else
        @setState
          error: locales.get('notPhoneNumber', @getLanguage())
    else
      @setState error: locales.get('unknownAccountType', @getLanguage())

  onBack: ->
    @setState showVerifyMobile: false

  onMobileVerify: (verifyCode) ->
    ajax.mobileSignInByVerifyCode
      data:
        randomCode: @state.randomCode
        verifyCode: verifyCode
        action: 'resetpassword'
      success: (resp) =>
        @setState showResetPassword: true, error: null
      error: (err) =>
        error = JSON.parse err.response
        @setState error: error.message

  onResetPassword: (password) ->
    ajax.mobileResetPassword
      data:
        newPassword: password
      success: (resp) =>
        controllers.routeSucceedResetting()
        @setState error: null
        setTimeout ->
          controllers.signInRedirect()
        , 3000
      error: (err) =>
        error = JSON.parse err.response
        @setState error: error.message

  onSubmit: (event) ->
    event.preventDefault()
    @onNext()

  onCaptchaSelect: (uid) ->
    @setState captchaUid: uid

  renderVerifyMobile: ->
    VerifyMobile
      store: @props.store
      onResend: @onNext
      onVerify: @onMobileVerify
      onBack: @onBack
      error: @state.error
      isLoading: @isLoading()

  renderResetPassword: ->
    ResetPassword
      language: @getLanguage(), onSubmit: @onResetPassword
      isLoading: @isLoading()

  renderGuideText: ->
    switch @state.tab
      when 'mobile' then locales.get('sendVerifyCode', @getLanguage())
      when 'email' then locales.get('sendVerifyEmail', @getLanguage())

  render: ->
    if @state.showResetPassword
      return @renderResetPassword()
    if @state.showVerifyMobile
      return @renderVerifyMobile()

    form className: 'forgot-password control-panel', onSubmit: @onSubmit,
      AccountSwitcher
        tab: @state.tab, onSwitch: @onTabSwitch
        mobileGuide: locales.get('resetPasswordWidthMobile', @getLanguage())
        emailGuide: locales.get('resetPasswordWidthEmail', @getLanguage())

      Space height: 15
      switch @state.tab
        when 'email'
          div className: 'as-line',
            input
              value: @getAccount(), onChange: @onAccountChange
              placeholder: locales.get('email', @getLanguage())
              type: 'email', autoFocus: true
            if detect.isEmail(@getAccount()) or detect.isMobile(@getAccount())
              span className: 'ok-icon icon icon-tick'
        when 'mobile'
          MobileInput
            language: @getLanguage()
            account: @getAccount(), onChange: @onMobileAccountChange
            autoFocus: true
      if @state.tab is 'mobile'
        div className: 'as-block vbox',
          Space height: 10
          CaptchaIcons
            lang: @getLanguage(), onSelect: @onCaptchaSelect, isDone: @state.captchaUid?
      Space height: 35
      if @state.error?
        div className: 'as-line',
          span className: 'hint-error', @state.error
          Space height: 15
      div className: 'as-line-filled',
        if @isLoading()
          button className: 'button is-primary is-disabled',
            @renderGuideText()
        else
          button className: 'button is-primary',
            @renderGuideText()
