React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
detect = require '../util/detect'
locales = require '../locales'
analytics = require '../util/analytics'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
MobileInput = React.createFactory require './mobile-input'
AccountSwitcher = React.createFactory require './account-switcher'
ThirdpartyEntries = React.createFactory require './thirdparty-entries'

{a, i, h3, div, form, span, input, button, strong, fieldset} = React.DOM

module.exports = React.createClass
  displayName: 'app-signin'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    account = @getAccount()

    tab: if (account[0] is '+') then 'mobile' else 'email'
    error: null
    quickLogin: @validUser()

  componentWillUnmount: ->
    @resetPassword()

  getUser: ->
    @props.store.get 'user'

  validUser: ->
    user = @getUser()
    return false if not user?
    return false if not Immutable.Map.isMap user

    hasLogin = user.has 'login'
    hasEmail = user.has 'emailAddress'
    hasPhone = user.has 'phoneNumber'
    hasUnions = user.has('unions') and user.get('unions').size > 0

    hasLogin or hasEmail or hasPhone or hasUnions

  detectUser: ->
    user = @getUser()

    account = =>
      switch user.get 'login'
        when 'email' then user.get 'emailAddress'
        when 'mobile' then user.get 'phoneNumber'
        else
          union = user.get 'unions'
          .find (union) =>
            union.get('refer') is user.get('login')

          if not union?
            return locales.get('undefinedAccount', @getLanguage())

          union.get 'showname'

    account()

  getAccount: ->
    @props.store.getIn(['client', 'account'])

  getPassword: ->
    @props.store.getIn(['client', 'password'])

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  onAccountChange: (event) ->
    @setState error: null
    controllers.updateAccount event.target.value

  onMobileAccountChange: (account) ->
    @setState error: null
    controllers.updateAccount account

  onPasswordChange: (event) ->
    @setState error: null
    controllers.updatePassword event.target.value

  onRouteSignUp: (event) ->
    event.preventDefault()
    controllers.routeSignUp()

  requestReset: (event) ->
    event.preventDefault()
    controllers.routeForgotPassword()

  onSignIn: ->
    if not detect.isValidPassword(@getPassword())
      @setState error: locales.get('passwordNoShortThan6', @getLanguage())
      return

    if @state.tab is 'email'
      if detect.isEmail @getAccount()
        @setState
          error: null
        ajax.emailSignIn
          data:
            emailAddress: @getAccount()
            password: @getPassword()
          success: (resp) =>
            controllers.logInRedirectWithData('email')
            @setState error: null
          error: (err) =>
            error = JSON.parse err.response
            @setState error: error.message
            analytics.loginError()
      else
        @setState
          error: locales.get('notEmail', @getLanguage())
    else if @state.tab is 'mobile'
      if detect.isMobile @getAccount()
        @setState
          error: null
        ajax.mobileSignIn
          data:
            phoneNumber: @getAccount()
            password: @getPassword()
          success: (resp) =>
            controllers.logInRedirectWithData('phone')
            @setState error: null
          error: (err) =>
            error = JSON.parse err.response
            @setState error: error.message
            analytics.loginError()
      else
        @setState
          error: locales.get('notPhoneNumber', @getLanguage())
    else
      @setState error: locales.get('unknownAccountType', @getLanguage())

  resetPassword: ->
    controllers.resetPassword()

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

  onSubmit: (event) ->
    event.preventDefault()
    @onSignIn()

  onGotoTalk: ->
    controllers.loginDirectWithData()

  onSwitchToOtherAccount: ->
    @setState
      quickLogin: false

  renderQuickLoginComponents: ->
    loginedUser = @detectUser()

    fieldset className: 'control-panel',
      div className: 'as-line-centered', "#{locales.get 'haveLoginedAccount', @getLanguage()}:"
      div className: 'as-line-centered',
        h3 {}, "#{loginedUser}"
      Space height: 35
      div className: 'as-line-filled',
        button className: 'button is-primary', onClick: @onGotoTalk,
          locales.get 'quickSignInJianliao', @getLanguage()
      Space height: 20
      div className: 'as-line-centered',
        a tabIndex: 0, className: 'link-guide', onClick: @onSwitchToOtherAccount,
          locales.get('switchToOtherAccount', @getLanguage())

  renderLoginComponents: ->
    fieldset className: 'control-panel',
      AccountSwitcher
        tab: @state.tab, onSwitch: @onTabSwitch
        mobileGuide: locales.get('signInWithMobile', @getLanguage())
        emailGuide: locales.get('signInWithEmail', @getLanguage())
      Space height: 35
      switch @state.tab
        when 'email'
          div className: 'as-line',
            input
              type: 'email', value: @getAccount(), onChange: @onAccountChange
              placeholder: locales.get('email', @getLanguage())
              autoFocus: true, name: 'email'
            if detect.isEmail(@getAccount())
              span className: 'ok-icon icon icon-tick'
        when 'mobile'
          MobileInput
            language: @getLanguage()
            account: @getAccount(), onChange: @onMobileAccountChange
            autoFocus: true
      Space height: 15, width: null
      div className: 'as-line',
        input
          type: 'password', value: @getPassword(), onChange: @onPasswordChange
          placeholder: locales.get('passwordNoShortThan6', @getLanguage())
          name: 'password'
        a tabIndex: 0, className: 'link-inside', onClick: @requestReset,
          locales.get('forgotPassword', @getLanguage())
      Space height: 35
      if @state.error
        div className: 'as-line',
          span className: 'hint-error', @state.error
          Space height: 15
      div className: 'as-line-filled',
        if @isLoading()
          button className: 'button is-primary is-disabled',
            locales.get('signInJianliao', @getLanguage())
        else
          button className: 'button is-primary',
            locales.get('signInJianliao', @getLanguage())
      Space height: 20, width: null
      div className: 'as-line-centered',
        span className: 'text-guide',
          locales.get('dontHaveAnAccount', @getLanguage())
        Space width: 5
        a tabIndex: 0, className: 'link-guide', onClick: @onRouteSignUp,
          locales.get('registerAccount', @getLanguage())
      Space height: 120
      a tabIndex: 0, className: 'old-user-guide', onClick: @requestReset,
        locales.get('oldUserPasswordGuide', @getLanguage())
      Space height: 15
      ThirdpartyEntries language: @getLanguage()

  render: ->
    form className: 'app-signin', onSubmit: @onSubmit,
      if @state.quickLogin
        @renderQuickLoginComponents()
      else
        @renderLoginComponents()
