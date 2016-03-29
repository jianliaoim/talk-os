# comment untouched Router

React = require 'react'
Immutable = require 'immutable'

dispatcher = require '../dispatcher'
lang = require '../locales/lang'
eventBus = require '../event-bus'

keyboard = require '../util/keyboard'
handlers = require '../guest/handlers'

guestActions = require '../guest/actions'

div    = React.createFactory 'div'
span   = React.createFactory 'span'
a      = React.createFactory 'a'
button = React.createFactory 'button'
input  = React.createFactory 'input'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'app-signup'

  propTypes:
    topics: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    name: ''
    email: ''
    isEmailValid: true

  onNameChange: (event) ->
    name = event.target.value
    @setState {name}

  onEmailChange: (event) ->
    email = event.target.value
    @setState {email, isEmailValid: true}

  onNameKeydown: (event) ->
    if event.keyCode is keyboard.enter
      @refs.email.focus()

  onEmailKeydown: (event) ->
    if event.keyCode is keyboard.enter
      @onSubmit()

  onSubmit: ->
    data =
      name: @state.name
      email: @state.email

    if @state.name.trim().length is 0
      return

    guestActions.userCreate data.name, data.email, undefined,
      (resp) ->
        handlers.registerUser resp
        handlers.joinTopic()
      (resp) =>
        console.error 'signup user error', resp
        @setState isEmailValid: false

  renderForm: ->
    # guest page gets only part of the data,
    # guessing topic name since there's only one topic
    topicName = @props.topics.first().first().get('topic')

    if topicName
      welcome = lang.getText('visiting-topic').replace('%s', topicName)
    else
      welcome = lang.getText('visiting-guest')
    emailClass = cx
      email: true
      'form-control': true
      'is-invalid': not @state.isEmailValid

    div className: 'box paragraph',
      div className: '', welcome
      div className: 'line',
        input
          className: 'name form-control', value: @state.name, type: 'text'
          placeholder: lang.getText('your-name')
          onChange: @onNameChange, onKeyDown: @onNameKeydown
      div className: 'line',
        input
          type: 'text', className: emailClass, ref: 'email', value: @state.email
          placeholder: lang.getText('email-optional')
          onChange: @onEmailChange, onKeyDown: @onEmailKeydown
        span
          className: 'email-help simpletip is-right'
          'data-tip': lang.getText('may-email-conversation')
          span className: 'icon icon-help muted'
      div className: 'line',
        button className: 'button is-primary is-extended', onClick: @onSubmit,
          lang.getText('join-topic')

  renderFooter: ->

    homeLink = 'https://jianliao.com'
    blogLink = 'https://jianliao.com/blog/'
    loginLink = 'https://account.jianliao.com/signin'
    signupLink = 'https://account.jianliao.com/signup'

    div className: 'footer',
      div className: 'sites line',
        a target: '_blank', className: 'button is-link', href: homeLink,
          lang.getText('home')
        a target: '_blank', className: 'button is-link', href: blogLink,
          lang.getText('blog')
        a target: '_blank', className: 'button is-link', href: loginLink,
          lang.getText('login')
        a target: '_blank', className: 'button is-link', href: signupLink,
          lang.getText('signup')
      div className: 'rights muted',
        'Copyright © 2012-2016 Teambition Ltd.'

  render: ->

    div className: 'app-signup',
      div className: "logo is-#{lang.getLang()}"
      @renderForm()
      @renderFooter()
