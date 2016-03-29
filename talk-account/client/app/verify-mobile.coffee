
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
MobileInput = React.createFactory require './mobile-input'

{div, input, form, button, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'verify-mobile'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired
    onResend: React.PropTypes.func.isRequired
    onVerify: React.PropTypes.func.isRequired
    onBack: React.PropTypes.func.isRequired
    error: React.PropTypes.string
    isLoading: React.PropTypes.bool.isRequired

  getInitialState: ->
    verifyCode: ''
    randomCode: null
    countdown: 60

  componentDidMount: ->
    @startTimer()

  componentWillUnmount: ->
    if @timer?
      clearInterval @timer

  getAccount: ->
    @props.store.getIn ['client', 'account']

  getLanguage: ->
    @props.store.getIn ['client', 'language']

  startTimer: ->
    @timer = setInterval @countdown, 1000

  countdown: ->
    if @state.countdown > 1
      @setState countdown: @state.countdown - 1
    else
      clearInterval @timer
      @timer = null
      @setState countdown: 0

  onCodeChange: (event) ->
    @setState verifyCode: event.target.value

  onVerify: ->
    @props.onVerify @state.verifyCode

  onBack: ->
    @props.onBack()

  onResend: ->
    if @state.countdown is 0
      @props.onResend()
      @setState countdown: 60
      @startTimer()

  onMobileChange: (account) ->
    controllers.updateAccount account

  onSubmit: (event) ->
    event.preventDefault()
    @onVerify()

  render: ->
    form className: 'verify-mobile control-panel vbox', onSubmit: @onSubmit,
      div className: 'as-line-centered',
        span className: 'hint-text', locales.get('inputMobileVerifyCode', @getLanguage())
      Space height: 15
      MobileInput
        language: @getLanguage()
        account: @getAccount(), onChange: @onMobileChange
      Space height: 15
      div className: 'as-line-filled',
        input
          value: @state.verifyCode, onChange: @onCodeChange
          type: 'text', placeholder: locales.get('verifyCode', @getLanguage())
        if @state.countdown > 1
          span className: 'resend-button is-disabled',
            locales.get('resend', @getLanguage())
            "(#{@state.countdown})"
        else
          a className: 'resend-button', onClick: @onResend,
            locales.get('resend', @getLanguage())
      Space height: 35
      if @props.error?
        div className: 'as-line',
          span className: 'hint-error', @props.error
          Space height: 15
      div className: 'as-line-filled',
        if @props.isLoading
          button className: 'button is-primary is-disabled',
            locales.get('verifyMobile', @getLanguage())
        else
          button className: 'button is-primary',
            locales.get('verifyMobile', @getLanguage())
