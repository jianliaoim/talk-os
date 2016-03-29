React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

time = require '../util/time'

lang = require '../locales/lang'

div  = React.createFactory 'div'
span = React.createFactory 'span'
a    = React.createFactory 'a'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'notify-upgrade'
  mixins: [PureRenderMixin]

  propTypes:
    onDismiss: T.func.isRequired

  getInitialState: ->
    wait: 20

  componentDidMount: ->
    @_timer = time.every 1000, @countDown

  countDown: ->
    if @state.wait > 0
    then @setState wait: (@state.wait - 1)
    else @onUpgrade()

  onUpgrade: ->
    clearInterval @_timer
    location.reload()

  onDismiss: ->
    clearInterval @_timer
    @props.onDismiss()

  render: ->

    div className: 'notify-upgrade',
      span null, lang.getText('new-version')
      lang.getText('will-update').replace('%s', @state.wait)
      span className: 'actions',
        a className: 'button is-small is-primary update', onClick: @onUpgrade,
          lang.getText('update')
        a className: 'button is-small is-default dismiss', onClick: @onDismiss,
          lang.getText('dismiss')
