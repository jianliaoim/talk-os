
React = require 'react'
Immutable = require 'immutable'
classnames = require 'classnames'

locales = require '../locales'

Space = React.createFactory require 'react-lite-space'

{div, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'account-switcher'

  propTypes:
    tab: React.PropTypes.string.isRequired
    onSwitch: React.PropTypes.func.isRequired
    emailGuide: React.PropTypes.string.isRequired
    mobileGuide: React.PropTypes.string.isRequired

  onSwitchEmail: ->
    if @props.tab isnt 'email'
      @props.onSwitch 'email'

  onSwitchMobile: ->
    if @props.tab isnt 'mobile'
      @props.onSwitch 'mobile'

  render: ->
    emailClass = classnames 'account-tab',
      'is-selected': @props.tab is 'email'
    mobileClass = classnames 'account-tab',
      'is-selected': @props.tab is 'mobile'
    div className: 'account-switcher',
      a className: mobileClass, onClick: @onSwitchMobile,
        @props.mobileGuide
      a className: emailClass, onClick: @onSwitchEmail,
        @props.emailGuide
