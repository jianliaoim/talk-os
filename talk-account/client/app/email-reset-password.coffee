
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
ResetPassword = React.createFactory require './reset-password'

{div, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'email-reset-password'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showResetPassword: false
    error: null

  componentDidMount: ->
    @loginWithResetToken()

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  getResetToken: ->
    decodeURIComponent @props.store.getIn(['router', 'query', 'resetToken'])

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  loginWithResetToken: ->
    ajax.emailSignInByVerifyCode
      data:
        resetToken: @getResetToken()
      success: (resp) =>
        @setState showResetPassword: true, error: null
      error: (err) =>
        error = JSON.parse err.response
        @setState error: error.message

  onPasswordChange: (event) ->
    @setState password: event.target.value

  onConfirmChange: (event) ->
    @setState confirm: event.target.value

  onResetPassword: (password) ->
    ajax.emailResetPassword
      data:
        newPassword: password
      success: (resp) =>
        controllers.routeSucceedResetting()
        @setState error: null
        setTimeout =>
          controllers.signInRedirect()
        , 3000
      error: (err) =>
        error = JSON.parse err.response
        @setState error: error.message

  renderResetPassword: ->
    ResetPassword
      language: @getLanguage(), onSubmit: @onResetPassword
      isLoading: @isLoading()

  render: ->
    if @state.showResetPassword
      return @renderResetPassword()

    div className: 'email-reset-password control-panel',
      div className: 'as-line-centered',
        if @state.error?
          span className: 'hint-error', @state.error
        else
          span className: 'hint-text', locales.get('checking', @getLanguage())
