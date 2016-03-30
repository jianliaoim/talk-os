React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang  = require '../locales/lang'
time  = require '../util/time'
config = require '../config'

Icon = React.createFactory require '../module/icon'

{ div, span, hr }  = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'user-menu'
  mixins: [PureRenderMixin]

  propTypes:
    onSettingsClick:  T.func.isRequired
    onDownloadClick:   T.func.isRequired
    onLogoutClick:    T.func.isRequired
    onPopoverClose:   T.func.isRequired
    onFeedbackClick:  T.func.isRequired

  onSettingsClick: ->
    @props.onSettingsClick()
    @props.onPopoverClose()

  onDownloadClick: ->
    @props.onDownloadClick()
    @props.onPopoverClose()

  onFeedbackClick: ->
    @props.onFeedbackClick()
    @props.onPopoverClose()

  onSupportClick: ->
    window.open '/site/support', true
    @props.onPopoverClose()

  onLogoutClick: ->
    time.delay 10, =>
      @props.onLogoutClick()
      @props.onPopoverClose()

  render: ->
    MenuItems = [
      { icon: 'cog-solid', text: 'profile-page', onClick: @onSettingsClick }
      { icon: 'download-solid', text: 'download-apps', onClick: @onDownloadClick }
      { icon: 'feedback', text: 'feedback', onClick: @onFeedbackClick }
      { icon: 'life-belt', text: 'help-center', onClick: @onSupportClick }
      { icon: 'log-out', text: 'logout', onClick: @onLogoutClick }
    ]

    div className: 'user-menu',
      MenuItems.map (item, index) ->
        div key: index, className: 'item line flex-horiz flex-vcenter', onClick: item.onClick,
          Icon name: item.icon, size: 18
          lang.getText item.text
      div className: 'item line is-version',
        span className: 'version',
          "v#{config.version}"
