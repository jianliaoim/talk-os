React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
InteAdding = React.createFactory require './inte-adding'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'inte-hooks'
  mixins: [PureRenderMixin]

  propTypes:
    onPageSwitch: T.func.isRequired
    intes: T.object.isRequired # immutable array

  onWebhookClick: (inteId) ->
    @props.onPageSwitch inteId

  renderHooks: ->
    intes = @props.intes.filter (value, key) ->
      value.get('isCustomized')
    intes.map (inte) =>
      onClick = =>
        @onWebhookClick inte.get('name')
      InteAdding inte: inte, onAddingClick: onClick, key: inte.get('name')

  render: ->

    div className: 'inte-hooks',
      @renderHooks()
