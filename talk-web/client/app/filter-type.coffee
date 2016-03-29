React = require 'react'
cx = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
keyboard = require '../util/keyboard'

LiteDropdown = React.createFactory require 'react-lite-dropdown'
div = React.createFactory 'div'

entries = ['all-types', 'type-file', 'type-rtf', 'type-url', 'type-snippet']

T = React.PropTypes

module.exports = React.createClass
  displayName: 'filter-type'
  mixins: [PureRenderMixin]

  propTypes:
    type: T.oneOf entries
    onChange: T.func.isRequired

  getInitialState: ->
    showMenu: false
    index: 0

  # events

  onItemClick: (type) ->
    @props.onChange type

  onMenuToggle: ->
    @setState showMenu: (not @state.showMenu)

  # renderers

  renderItems: ->
    entries.map (item) =>
      onClick = => @onItemClick item
      if @props.type
        className = cx 'item', 'is-selected': item is @props.type
      else
        className = cx 'item', 'is-selected': item is entries[0]
      div key: item, className: className, onClick: onClick, lang.getText(item)

  render: ->
    LiteDropdown
      displayText: lang.getText(@props.type or entries[0])
      defaultText: lang.getText entries[0]
      name: 'filter-type'
      show: @state.showMenu
      onToggle: @onMenuToggle
      @renderItems()
