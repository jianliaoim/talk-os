cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'
userActions = require '../actions/user'
notifyActions = require '../actions/notify'

lang = require '../locales/lang'

div = React.createFactory 'div'
input = React.createFactory 'input'
button = React.createFactory 'button'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'profile-name'

  propTypes:
    onComplete: T.func.isRequired
    name: T.string.isRequired

  getInitialState: ->
    name: @props.name or ''

  onChange: (event) ->
    @setState name: event.target.value

  onComplete: ->
    _userId = query.userId(recorder.getState())
    if 0 < @state.name.length < 30
      userActions.userUpdate _userId, name: @state.name
      @props.onComplete()
    else
      notifyActions.warn lang.getText('invalid-length')

  render: ->
    buttonClassName = cx
      'button': true
      'is-primary': true
      'is-disabled': @state.name.length is 0

    div className: 'profile-name profile-wrapper',
      div className: 'name',
        input
          className: 'input'
          placeholder: lang.getText 'enter-name'
          defaultValue: @state.name
          onChange: @onChange
      button className: buttonClassName, onClick: @onComplete, lang.getText 'complete'
