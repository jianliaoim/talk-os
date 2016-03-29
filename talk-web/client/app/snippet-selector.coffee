React = require 'react'
Immutable = require 'immutable'

snippetUtil = require '../util/snippet'

LiteDropdown = React.createFactory require 'react-lite-dropdown'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div } = React.DOM
T = React.PropTypes

isLoadedCodeEditor = false

module.exports = React.createClass
  displayName: 'snippet-selector'
  mixins: [ PureRenderMixin ]

  propTypes:
    codeType: T.string.isRequired
    codeAssets: T.instanceOf(Immutable.OrderedMap).isRequired

  getInitialState: ->
    showSelector: false

  onToggle: ->
    @setState
      showSelector: not @state.showSelector

  render: ->
    name = snippetUtil.getName @props.codeType

    div className: 'snippet-selector',
      LiteDropdown
        name: 'snippet-selector'
        show: @state.showSelector
        onToggle: @onToggle,
        defaultText: name
        displayText: name
        @props.codeAssets
          .map (value, key) =>
            onClick = => @props.onClick key
            div
              key: key, className: 'item'
              onClick: onClick
              value.get 'name'
          .toList()
