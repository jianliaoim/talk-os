React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

roomActions  = require '../actions/room'
notifyActions = require '../actions/notify'

div    = React.createFactory 'div'
span   = React.createFactory 'span'
p      = React.createFactory 'p'
button = React.createFactory 'button'
input  = React.createFactory 'input'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'topic-guest-mode'

  mixins: [PureRenderMixin]

  propTypes:
    topic: T.instanceOf(Immutable.Map).isRequired
    hasPermission: T.bool.isRequired

  onUrlOver: (event) ->
    event.target.select()

  onRegenerateClick: ->
    roomActions.roomUpdateGuest @props.topic.get('_id'), true

  onDisableClick: ->
    roomActions.roomUpdateGuest @props.topic.get('_id'), false

  onEnableClick: ->
    roomActions.roomUpdateGuest @props.topic.get('_id'), true

  onVisibleClick: ->
    if @props.hasPermission
      newData = isGuestVisible: not @props.topic.get('isGuestVisible')
      roomActions.roomUpdate @props.topic.get('_id'), newData, (resp) ->
        if resp.isGuestVisible
          text = lang.getText('history-visible-to-guests')
        else
          text = lang.getText('history-invisible-to-guests')
        notifyActions.info text

  render: ->
    div className: 'modal-paragraph',
      div className: 'modal-name', lang.getText('guest-mode')
      if @props.topic.get('guestUrl')
      then p className: 'muted', lang.getText('guest-mode-opened')
      else p className: 'muted', lang.getText('guest-mode-intro')

      if @props.topic.get('guestUrl')?
        p className: 'line display-url',
          input
            type: 'text'
            className: 'url form-control', onMouseEnter: @onUrlOver
            value: @props.topic.get('guestUrl'), onChange: (->)
          if @props.hasPermission
            span className: 'muted icon icon-refresh', onClick: @onRegenerateClick
          if @props.hasPermission
            button className: 'button is-danger', onClick: @onDisableClick,
              lang.getText('disable–guest-mode')
      else
        if @props.hasPermission
          p className: 'line',
            button className: 'button is-default', onClick: @onEnableClick,
              lang.getText('generate–guest-link')
      if @props.topic.get('guestUrl')?
        spanClass = cx 'icon', 'history',
          'icon-tick': @props.topic.get('isGuestVisible')
          'is-disabled': not @props.hasPermission
        p className:'radio', onClick: @onVisibleClick,
          span className: spanClass
          lang.getText('guest-views-history')
