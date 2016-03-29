React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
dispatcher = require '../dispatcher'

userActions = require '../actions/user'

div    = React.createFactory 'div'
button = React.createFactory 'button'
input  = React.createFactory 'input'

cx = require 'classnames'

module.exports = React.createClass
  displayName: 'settings-profile'
  mixins: [PureRenderMixin]

  propTypes:
    data: React.PropTypes.instanceOf(Immutable.Map).isRequired
    onModalClose: React.PropTypes.func.isRequired

  getInitialState: ->
    name: @props.data.get('name')
    email: @props.data.get('email')

  needSave: ->
    giveName = @state.name.length > 0
    nameChanged = @state.name isnt @props.data.get('name')
    emailChanged = @state.email isnt @props.data.get('email')
    giveName and (nameChanged or emailChanged)

  onNameChange: (event) ->
    @setState name: event.target.value

  onEmailChange: (event) ->
    @setState email: event.target.value

  onSave: ->
    if @needSave()
      data =
        name: @state.name
        email: @state.email
      userActions.userUpdate @props.data.get('_id'), data, @onModalClose

  onModalClose: ->
    @props.onModalClose()

  render: ->
    style =
      padding: 20

    div className: 'settings-profile paragraph', style: style,
      div className: 'form-group',
        div className: '', lang.getText('name')
        input
          type: 'text', className: 'form-control', value: @state.name
          onChange: @onNameChange
      div className: 'form-group',
        div className: '', lang.getText('email-optional')
        input
          type: 'text', className: 'form-control', value: @state.email
          onChange: @onEmailChange
      button
        className: cx
          'button': true
          'is-primary': true
          'is-extended': true
          'last-line': true
          'is-disabled': not @needSave()
        onClick: @onSave
        lang.getText('save')
