React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang  = require '../locales/lang'
time  = require '../util/time'
config = require '../config'

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

  onHomePageClick: ->
    window.open '/site', true
    @props.onPopoverClose()

  onLogoutClick: ->
    time.delay 10, =>
      @props.onLogoutClick()
      @props.onPopoverClose()

  renderDevButtons: ->
    if __DEV__
      [
        div
          key: 'tourguide'
          className: 'item line'
          onClick: =>
            @props.onPopoverClose()
            require('../tour-guide').start()
          '开启用户引导'
      ]

  render: ->
    div className: 'user-menu',
      div className: 'item line', onClick: @onSettingsClick,
        span className: 'icon icon-cog'
        lang.getText 'profile-page'
      div className: 'item line', onClick: @onDownloadClick,
        span className: 'icon icon-download'
        lang.getText 'download-apps'
      div className: 'item line', onClick: @onHomePageClick,
        span className: 'icon icon-link'
        lang.getText 'talk-home-page'
      div className: 'item line', onClick: @onFeedbackClick,
        span className: 'icon icon-comments'
        lang.getText 'feedback'
      div
        className: 'item line'
        onClick: @onLogoutClick,
        span className: 'icon icon-quit2'
        lang.getText 'logout'
      div className: 'item line is-version',
        span className: 'version',
          "v#{config.version}"
