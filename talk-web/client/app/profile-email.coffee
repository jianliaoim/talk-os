cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'
userActions = require '../actions/user'
notifyActions = require '../actions/notify'

lang = require '../locales/lang'

util = require '../util/util'

div = React.createFactory 'div'
input = React.createFactory 'input'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'profile-email'

  propTypes:
    onComplete: T.func.isRequired
    email: T.string.isRequired

  getInitialState: ->
    email: @props.email

  onChange: (event) ->
    @setState email: event.target.value

  onComplete: ->
    _userId = query.userId(recorder.getState())
    if @state.email.length isnt 0 and util.isEmail @state.email
      userActions.userUpdate _userId, email: @state.email
      @props.onComplete()
    else
      notifyActions.error lang.getText 'email-invalid'

  render: ->
    buttonClassName = cx
      'button': true
      'is-disabled': @state.email.length is 0

    div className: 'profile-email profile-wrapper',
      div className: 'email',
        input
          className: 'input'
          placeholder: lang.getText 'enter-email'
          defaultValue: @state.email
          onChange: @onChange
      div className: buttonClassName, onClick: @onComplete, lang.getText 'complete'
