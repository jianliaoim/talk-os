React = require 'react'
lang  = require '../locales/lang'
PureRenderMixin = require 'react-addons-pure-render-mixin'

favoriteActions  = require '../actions/favorite'

p                = React.createFactory 'p'
div              = React.createFactory 'div'
span             = React.createFactory 'span'
LightDialog      = React.createFactory require '../module/light-dialog'

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'favorites-deleter'
  mixins: [PureRenderMixin]

  propTypes:
    _messageId: T.string.isRequired

  getInitialState: ->
    showDeleter: false

  onDeleterClose: ->
    @setState showDeleter: false

  onDeleterShow: ->
    @setState showDeleter: true

  onRemoveFavorite: ->
    favoriteActions.removeFavorite @props._messageId

  renderDeleter: ->
    LightDialog
      flexible: true
      show: @state.showDeleter
      onCloseClick: @onDeleterClose
      onConfirm: @onRemoveFavorite
      confirm: l('confirm')
      cancel: l('cancel')
      content: lang.getText('favorite-deleter-tip')

  render: ->
    div className: 'favorite-deleter', onClick: @onDeleterShow,
      span className: 'ti ti-trash deleter'
      @renderDeleter()
