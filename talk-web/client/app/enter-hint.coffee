React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

settingsActions = require '../actions/settings'
lang = require '../locales/lang'

Tooltip = React.createFactory require '../module/tooltip'

{ span } = React.DOM
T = React.PropTypes

ENTER_METHODS = Immutable.List(['enter', 'ctrlEnter', 'shiftEnter'])

HINT_TEXTS = ->
  enter: "Shift + Enter #{lang.getText('wrap')}#{lang.getText('comma')} Enter #{lang.getText('send')}"
  ctrlEnter: "Enter #{lang.getText('wrap')}#{lang.getText('comma')} Ctrl + Enter #{lang.getText('send')}"
  shiftEnter: "Enter #{lang.getText('wrap')}#{lang.getText('comma')} Shift + Enter #{lang.getText('send')}"

module.exports = React.createClass
  displayName: 'enter-hint'

  mixins: [PureRenderMixin]

  propTypes:
    enterMethod: T.string.isRequired

  statics:
    getEnterMethods: ->
      ENTER_METHODS

  onClick: ->
    currentMethod = @props.enterMethod
    index = ENTER_METHODS.indexOf(currentMethod)
    nextMethod = ENTER_METHODS.get((index + 1) % ENTER_METHODS.size)
    settingsActions.changeEnterMethod(nextMethod)

  render: ->
    Tooltip template: lang.getText('enter-hint-tooltip'), options: {position: 'top center'},
      span
        className: 'enter-hint',
        onClick: @onClick,
        HINT_TEXTS()[@props.enterMethod]
