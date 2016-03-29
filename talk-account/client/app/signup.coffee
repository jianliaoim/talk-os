
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
detect = require '../util/detect'
locales = require '../locales'
analytics = require '../util/analytics'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
MobileInput = React.createFactory require './mobile-input'
VerifyMobile = React.createFactory require './verify-mobile'
CaptchaIcons = React.createFactory require './captcha-icons'
AccountSwitcher = React.createFactory require './account-switcher'
ThirdpartyEntries = React.createFactory require './thirdparty-entries'

{div, input, form, button, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'app-signup'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    account = @getAccount()
    if detect.isQQEmail account
      error = locales.get 'warningAboutQQEmail', @getLanguage()

    tab: if (account[0] is '+') then 'mobile' else 'email'
    confirm: ''
    randomCode: null
    showVerifyMobile: false
    error: error or null
    captchaUid: null

  componentWillUnmount: ->
    @resetPassword()

  getAccount: ->
    @props.store.getIn ['client', 'account']

  getPassword: ->
    @props.store.getIn ['client', 'password']

  getLanguage: ->
    @props.store.getIn ['client', 'language']

  isLoading: ->
    @props.store.getIn ['client', 'isLoading']

  isAccountOk: ->
    detect.isEmail(@getAccount()) or detect.isMobile(@getAccount())

  isPasswordOk: ->
    detect.isValidPassword(@getPassword())

  isConfirmOk: ->
    @isPasswordOk() and (@getPassword() is @state.confirm)

  onAccountChange: (event) ->
    if detect.isQQEmail event.target.value
      error = locales.get 'warningAboutQQEmail', @getLanguage()

    @setState error: error or null
    controllers.updateAccount event.target.value

  onMobileAccountChange: (account) ->
    @setState error: null
    controllers.updateAccount account

  onPasswordChange: (event) ->
    @setState error: null
    controllers.updatePassword event.target.value

  onConfirmChange: (event) ->
    @setState error: null, confirm: event.target.value

  onRouteSignIn: (event) ->
    event.preventDefault()
    controllers.routeSignIn()

  onTabSwitch: (tab) ->
    @setState
      tab: tab
      error: null
      captchaUid: null
    @resetPassword()
    if tab is 'email'
      controllers.updateAccount ''
    else
      controllers.updateAccount '+86'

  onCaptchaSelect: (uid) ->
    @setState captchaUid: uid

  onSignUp: ->
    if @isConfirmOk()
      if @state.tab is 'email'
        if detect.isEmail @getAccount()
          ajax.emailSignUp
            data:
              emailAddress: @getAccount()
              password: @getPassword()
            success: (resp) =>
              controllers.registerRedirectWithData('email')
              @setState error: null
            error: (err) =>
              error = JSON.parse err.response
              @setState error: error.message
              analytics.registerError()
        else
          @setState
            error: locales.get('notEmail', @getLanguage())
      else if @state.tab is 'mobile'
        if detect.isMobile @getAccount()
          if @state.captchaUid?
            ajax.mobileSendVerifyCode
              data:
                phoneNumber: @getAccount()
                action: 'signup'
                password: @getPassword()
                uid: @state.captchaUid
              success: (resp) =>
                @setState error: null, randomCode: resp.randomCode, showVerifyMobile: true
              error: (err) =>
                error = JSON.parse err.response
                @setState error: error.message
          else
            @setState
              error: locales.get('captchaIsRequired', @getLanguage())
        else
          @setState
            error: locales.get('notPhoneNumber', @getLanguage())
      else
        @setState error: locales.get('unknownAccountType', @getLanguage())
    else
      @setState error: locales.get('passwordFormatWrong', @getLanguage())

  onMobileVerify: (verifyCode) ->
    ajax.mobileSignInByVerifyCode
      data:
        randomCode: @state.randomCode
        verifyCode: verifyCode
        action: 'signin'
      success: (resp) =>
        controllers.registerRedirectWithData('phone')
        @setState error: null
      error: (err) =>
        error = JSON.parse err.response
        @setState error: error.message
        analytics.registerError()

  onBack: ->
    @setState showVerifyMobile: false

  onSubmit: (event) ->
    event.preventDefault()
    @onSignUp()

  renderOkIcon: ->
    span className: 'ok-icon icon icon-tick'

  renderVerifyMobile: ->
    VerifyMobile
      store: @props.store
      onResend: @onSignUp
      onVerify: @onMobileVerify
      onBack: @onBack
      error: @state.error
      isLoading: @isLoading()

  resetPassword: ->
    controllers.resetPassword()

  render: ->
    if @state.showVerifyMobile
      return @renderVerifyMobile()

    form className: 'app-signup control-panel', onSubmit: @onSubmit,
      AccountSwitcher
        tab: @state.tab, onSwitch: @onTabSwitch
        emailGuide: locales.get('signUpWithEmail', @getLanguage())
        mobileGuide: locales.get('signUpWithMobile', @getLanguage())
      Space height: 20
      switch @state.tab
        when 'email'
          div className: 'as-line',
            input
              type: 'email', value: @getAccount(), onChange: @onAccountChange
              placeholder: locales.get('email', @getLanguage())
              autoFocus: true
            if @isAccountOk()
              @renderOkIcon()
        when 'mobile'
          MobileInput
            language: @getLanguage()
            account: @getAccount(), onChange: @onMobileAccountChange
            autoFocus: true
      Space height: 10
      div className: 'as-line',
        input
          type: 'password', value: @getPassword(), onChange: @onPasswordChange
          placeholder: locales.get('passwordNoShortThan6', @getLanguage())
        if @isPasswordOk()
          @renderOkIcon()
      Space height: 10
      div className: 'as-line',
        input
          type: 'password', value: @state.confirm, onChange: @onConfirmChange
          placeholder: locales.get('confirmPassword', @getLanguage())
        if @isConfirmOk()
          @renderOkIcon()
      if @state.tab is 'mobile'
        div className: '',
          Space height: 10
          CaptchaIcons lang: @getLanguage(), onSelect: @onCaptchaSelect, isDone: @state.captchaUid?
      Space height: 35
      if @state.error?
        div className: 'as-line',
          span className: 'hint-error', @state.error
          Space height: 15
      div className: 'as-line-filled',
        if @isLoading()
          button className: 'button is-primary is-disabled',
            locales.get('signUpJianliao', @getLanguage())
        else
          button className: 'button is-primary',
            locales.get('signUpJianliao', @getLanguage())
      Space height: 20
      div className: 'as-line-centered',
        span className: 'text-guide',
          locales.get('alreadyHaveAccount', @getLanguage())
        Space width: 5
        a className: 'link-guide', onClick: @onRouteSignIn,
          locales.get('signIn', @getLanguage())
      Space height: 120
      ThirdpartyEntries language: @getLanguage()
