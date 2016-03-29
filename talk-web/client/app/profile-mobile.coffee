cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'
userActions = require '../actions/user'

lang = require '../locales/lang'

div = React.createFactory 'div'
input = React.createFactory 'input'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'profile-name'

  propTypes:
    onComplete: T.func.isRequired
    mobile: T.string.isRequired

  getInitialState: ->
    mobile: @props.mobile

  onChange: (event) ->
    @setState mobile: event.target.value

  onComplete: ->
    _userId = query.userId(recorder.getState())
    if @state.mobile.length isnt 0
      userActions.userUpdate _userId, mobile: @state.mobile
      @props.onComplete()

  render: ->
    buttonClassName = cx
      'button': true
      'is-disabled': @state.mobile.length is 0

    div className: 'profile-mobile profile-wrapper',
      div className: 'mobile',
        input
          className: 'input'
          placeholder: lang.getText 'enter-contact'
          defaultValue: @state.mobile
          onChange: @onChange
      div className: buttonClassName, onClick: @onComplete, lang.getText 'complete'
