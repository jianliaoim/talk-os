
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
detect = require '../util/detect'
config = require '../config'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
Dialog = React.createFactory require('react-lite-layered').Dialog

{div, button, form, input, img, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'app-accounts'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    error: null
    showConfirm: false
    refer: null

  # methods

  getAccounts: ->
    @props.store.getIn ['page', 'accounts']

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  isChangingBinding: ->
    # /bind-mobile?action=change
    @props.store.getIn(['router', 'query', 'action']) is 'change'

  # events

  onEmailChange: ->
    @setState showConfirm: true, refer: 'email'

  onEmailBind: ->
    controllers.redirectBindEmail()

  onMobileChange: ->
    @setState showConfirm: true, refer: 'mobile'

  onMobileBind: ->
    controllers.redirectMobileBind()

  # reusing unbind
  onUnbind: ->
    if @state.refer is 'email'
      controllers.redirectChangeEmail()
    else if @state.refer is 'mobile'
      controllers.redirectMobileChange()
    else
      @setState error: false
      ajax.unionUnbindX
        refer: @state.refer
        success: (resp) =>
          controllers.finishUnbind @state.refer
        error: (err) =>
          error = JSON.parse err.response
          @setState error: true

  onTeambitionUnbind: ->
    @setState refer: 'teambition', showConfirm: true

  onTeambitionBind: ->
    # also use this to "change"
    controllers.redirectBind 'teambition'

  onGithubUnbind: ->
    @setState refer: 'github', showConfirm: true

  onGithubBind: ->
    # also use this to "change"
    controllers.redirectBind 'github'

  onWeiboUnbind: ->
    @setState refer: 'weibo', showConfirm: true

  onWeiboBind: ->
    # also use this to "change"
    controllers.redirectBind 'weibo'

  onDialogClose: ->
    @setState showConfirm: false

  # renderers

  renderLocale: (key) ->
    locales.get key, @getLanguage()

  renderEmail: ->
    accounts = @getAccounts()
    email = accounts.get 'emailAddress'

    div className: 'account-line hbox',
      div className: 'account-name',
        @renderLocale('email')
      div className: 'account-status',
        if email
          email
        else
          span className: 'text-guide', @renderLocale('notBinded')
      div className: 'account-control',
        if email?
          a className: 'as-link', onClick: @onEmailChange, @renderLocale('change')
        else
          a className: 'as-link', onClick: @onEmailBind, @renderLocale('bind')

  renderMobile: ->
    accounts = @getAccounts()
    mobile = accounts.get 'phoneNumber'

    div className: 'account-line hbox',
      div className: 'account-name',
        @renderLocale('mobile')
      div className: 'account-status',
        if mobile?
          mobile
        else
          span className: 'text-guide', @renderLocale('notBinded')
      div className: 'account-control',
        if mobile?
          a className: 'as-link', onClick: @onMobileChange, @renderLocale('change')
        else
          a className: 'as-link', onClick: @onMobileBind, @renderLocale('bind')

  renderTeambition: ->
    accounts = @getAccounts()
    teambitionInfo = accounts.get('unions').find (binding) ->
      binding.get('login') is 'teambition'

    div className: 'account-line hbox',
      div className: 'account-name', 'Teambition'
      if teambitionInfo?
        div className: 'account-status',
          img className: 'account-avatar', src: teambitionInfo.get('avatarUrl')
          Space width: 10
          span null, teambitionInfo.get('showname')
      else
        div className: 'account-status',
          span className: 'text-guide', @renderLocale('notBinded')
      if teambitionInfo?
        div className: 'account-control',
          a className: 'as-link', onClick: @onTeambitionUnbind, @renderLocale('unbind')
      else
        div className: 'account-control',
          a className: 'as-link', onClick: @onTeambitionBind, @renderLocale('bind')

  renderGitHub: ->
    accounts = @getAccounts()
    githubInfo = accounts.get('unions').find (binding) ->
      binding.get('login') is 'github'

    div className: 'account-line hbox',
      div className: 'account-name', 'GitHub'
      if githubInfo?
        div className: 'account-status',
          img className: 'account-avatar', src: githubInfo.get('avatarUrl')
          Space width: 10
          span null, githubInfo.get('showname')
      else
        div className: 'account-status',
          span className: 'text-guide', @renderLocale('notBinded')
      if githubInfo?
        div className: 'account-control',
          a className: 'as-link', onClick: @onGithubUnbind, @renderLocale('unbind')
          Space width: 10
          a className: 'as-link', onClick: @onGithubBind, @renderLocale('change')
      else
        div className: 'account-control',
          a className: 'as-link', onClick: @onGithubBind, @renderLocale('bind')

  renderWeibo: ->
    accounts = @getAccounts()
    weiboInfo = accounts.get('unions').find (binding) ->
      binding.get('login') is 'weibo'

    div className: 'account-line hbox',
      div className: 'account-name',
        @renderLocale('weibo')
      if weiboInfo?
        div className: 'account-status',
          img className: 'account-avatar', src: weiboInfo.get('avatarUrl')
          Space width: 10
          span null, weiboInfo.get('showname')
      else
        div className: 'account-status',
          span className: 'text-guide', @renderLocale('notBinded')
      if weiboInfo?
        div className: 'account-control',
          a className: 'as-link', onClick: @onWeiboUnbind, @renderLocale('unbind')
          Space width: 10
          a className: 'as-link', onClick: @onWeiboBind, @renderLocale('change')
      else
        div className: 'account-control',
          a className: 'as-link', onClick: @onWeiboBind, @renderLocale('bind')

  renderDialog: ->
    if @state.refer in ['email', 'mobile']
      guideText = @renderLocale('changeWarning')
    else
      guideText = @renderLocale('changeWarning')

    Dialog
      cancel: @renderLocale('cancel')
      confirm: @renderLocale('confirm')
      onCloseClick: @onDialogClose
      onConfirm: @onUnbind
      show: @state.showConfirm
      content: guideText

  render: ->
    accounts = @getAccounts()

    div className: 'app-accounts wide-panel',
      div className: 'as-head',
        span className: 'text-guide', @renderLocale 'accountsBinding'
      Space height: 15
      div className: 'as-body',
        @renderEmail()
        div className: 'block-divider'
        @renderMobile()
        div className: 'block-divider'
        @renderTeambition()
        div className: 'block-divider'
        @renderGitHub()
        div className: 'block-divider'
        @renderWeibo()
      @renderDialog()
