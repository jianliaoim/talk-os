React = require 'react'
cx = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

LiteDropdown = React.createFactory require 'react-lite-dropdown'
div = React.createFactory 'div'

'day, week, month, quarter'

entries = [
  'time-range-one-day' # 一天以内, 后端 "day"
  'time-range-one-week' # 一周以内, 后端 "week"
  'time-range-one-month' # 一月以内, 后端 "month"
  'time-range-quarter' # 三月以内, 后端 "quarter"
]

T = React.PropTypes

module.exports = React.createClass
  displayName: 'filter-time-range'
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
    defaultEntry = entries[3]
    LiteDropdown
      displayText: lang.getText(@props.type or defaultEntry)
      defaultText: lang.getText defaultEntry
      name: 'filter-time-range'
      show: @state.showMenu
      onToggle: @onMenuToggle
      @renderItems()
