React = require 'react'
lang = require '../locales/lang'

div  = React.createFactory 'div'
span = React.createFactory 'span'

module.exports = React.createClass
  displayName: 'user-menu'

  propTypes:
    onSettingsClick: React.PropTypes.func.isRequired
    onLogoutClick: React.PropTypes.func.isRequired
    onPopoverClose: React.PropTypes.func.isRequired

  onSettingsClick: ->
    @props.onSettingsClick()
    @props.onPopoverClose()

  onLogoutClick: ->
    @props.onLogoutClick()
    @props.onPopoverClose()

  render: ->

    div className: 'user-menu',
      div className: 'item line', onClick: @onSettingsClick,
        span className: 'icon icon-cog'
        lang.getText('user-preferences')
      div className: 'item line', onClick: @onLogoutClick,
        span className: 'icon icon-quit2'
        lang.getText('logout')
