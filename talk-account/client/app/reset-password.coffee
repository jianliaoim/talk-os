
React = require 'react'
Immutable = require 'immutable'

detect = require '../util/detect'
locales = require '../locales'

Space = React.createFactory require 'react-lite-space'

{div, input, form, button, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'reset-password'

  propTypes:
    onSubmit: React.PropTypes.func.isRequired
    language: React.PropTypes.string.isRequired
    isLoading: React.PropTypes.bool.isRequired

  getInitialState: ->
    password: ''
    confirm: ''
    error: null

  isPasswordOk: ->
    detect.isValidPassword(@state.password)

  isConfirmOk: ->
    @isPasswordOk() and (@state.password is @state.confirm)

  onPasswordChange: (event) ->
    @setState password: event.target.value, error: null

  onConfirmChange: (event) ->
    @setState confirm: event.target.value, error: null

  onResetPassword: ->
    if @isConfirmOk()
      @props.onSubmit @state.password
    else
      @setState error: locales.get('passwordFormatWrong', @props.language)

  onSubmit: (event) ->
    event.preventDefault()
    @onResetPassword()

  renderOkIcon: ->
    span className: 'ok-icon icon icon-tick'

  render: ->
    form className: 'reset-password control-panel', onSubmit: @onSubmit,
      div className: 'as-line-centered',
        span className: 'hint-title', locales.get('setNewPassword', @props.language)
      Space height: 35
      div className: 'as-line',
        input
          value: @state.password, onChange: @onPasswordChange
          type: 'password', placeholder: locales.get('passwordNoShortThan6', @props.language)
        if @isPasswordOk()
          @renderOkIcon()
      Space height: 15
      div className: 'as-line',
        input
          value: @state.confirm, onChange: @onConfirmChange
          type: 'password', placeholder: locales.get('confirmPassword', @props.language)
        if @isConfirmOk()
          @renderOkIcon()
      Space height: 35
      if @state.error?
        div className: 'as-line',
          span className: 'hint-error', @state.error
          Space height: 15
      div className: 'as-line-filled',
        if @props.isLoading
          button className: 'button is-primary is-disabled',
            locales.get('confirmChange', @props.language)
        else
          button className: 'button is-primary',
            locales.get('confirmChange', @props.language)
