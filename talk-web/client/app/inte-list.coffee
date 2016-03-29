React = require 'react'
immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

search = require '../util/search'

InteAdding = React.createFactory require './inte-adding'
SearchBox = React.createFactory require('react-lite-misc').SearchBox
InteAdding      = React.createFactory require '../app/inte-adding'

div = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'inte-list'
  mixins: [PureRenderMixin]

  propTypes:
    onPageSwitch: T.func.isRequired
    intes: T.object.isRequired # immutable array
    _teamId: T.string
    _roomId: T.string

  getInitialState: ->
    query: ''

  onInteAddClick: (inteId) ->
    @props.onPageSwitch inteId

  onQueryChange: (value) ->
    @setState query: value

  renderInteList: ->
    language = lang.getLang()
    intes = @props.intes.filter (value, key) ->
      not value.get('isCustomized')
    thirdPartyIntes = search.immutableInteNames intes, @state.query, language
    thirdPartyIntes.map (inte) =>
      onClick = =>
        @onInteAddClick inte.get('name')
      InteAdding inte: inte, onAddingClick: onClick, key: inte.get('name')

  render: ->
    locale = lang.getText('find-by-name')

    div className: 'inte-list lm-content',
      div className: 'filter',
        SearchBox value: @state.query, onChange: @onQueryChange, locale: locale, autoFocus: false
      @renderInteList()
