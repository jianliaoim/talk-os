React = require 'react'
keycode = require 'keycode'
Immutable = require 'immutable'
classnames = require 'classnames'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'

search = require '../util/search'
dom = require '../util/dom'

LightDropdown = React.createFactory require '../module/light-dropdown'

hr = React.createFactory 'hr'
div = React.createFactory 'div'
input = React.createFactory 'input'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'filter-tag'
  mixins: [PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    onChange: T.func.isRequired
    _tagId: T.string
    hasTag: T.bool

  getInitialState: ->
    query: ''
    showMenu: false
    index: 0

  componentDidMount: ->
    @setState index: @getDefaultIndex()

  componentDidUpdate: ->
    @handScroll()

  # user methods

  getDefaultIndex: ->
    if @props._tagId
      (@filterTags().findIndex (tag) => tag.get('_id') is @props._tagId) + 2
    else if @props.hasTag
      1
    else 0

  filterTags: ->
    tags = query.tagsBy(recorder.getState(), @props._teamId) or Immutable.List()
    tags = search.forTags tags, @state.query

  getListLength: ->
    length = @filterTags().size
    if @state.query.length is 0
      length += 2
    length

  moveUp: ->
    if @state.index is 0
      @setState index: (@getListLength() - 1)
    else
      @setState index: @state.index - 1

  moveDown: ->
    if (@state.index + 1) >= @getListLength()
      @setState index: 0
    else
      @setState index: @state.index + 1

  selectCurrent: ->
    tags = @filterTags()
    if (@state.query.length is 0)
      switch @state.index
        when 0
          @props.onChange undefined, false
        when 1
          @props.onChange undefined, true
        else
          current = @state.index - 2
          tag = tags.get(current)
          @props.onChange tag.get('_id')
    else
      tags = @filterTags()
      tag = tags.get(@state.index)
      @props.onChange tag.get('_id')
    @onMenuToggle()

  handScroll: ->
    unless @refs.scroll?
      return
    each = 40
    hrHeight = 11
    scrollEl = @refs.scroll

    totalHeight = scrollEl.clientHeight
    top = scrollEl.scrollTop

    current = @state.index

    startY = current * each
    if (@state.query.length > 0) and (current >= 2)
      startY += hrHeight

    if ((startY - top) < 0) or ((startY + each) - top > totalHeight)
      y = startY - totalHeight / 2
      dom.smoothScrollTo scrollEl, 0, y

  # events

  onInputClick: (event) ->
    event.stopPropagation()

  onQueryChange: (event) ->
    @setState query: event.target.value.trim(), index: 0

  onItemClick: (tag, index) ->
    @props.onChange tag.get('_id'), true
    if @state.query.length > 0
      @setState index: index
    else
      @setState index: index + 2

  onAllClick: ->
    @props.onChange undefined, false
    @setState index: 0

  onAllTagClick: ->
    @props.onChange undefined, true
    @setState index: 1

  onMenuToggle: ->
    index = @getDefaultIndex()
    @setState
      index: index
      showMenu: not @state.showMenu

  onKeyDown: (event) ->
    switch keycode(event.keyCode)
      when 'up' then @moveUp()
      when 'down' then @moveDown()
      when 'enter' then @selectCurrent()

  renderTags: ->
    tags = @filterTags()
    if @state.query.length is 0
      current = @state.index - 2
    else
      current = @state.index

    tags.map (tag, index) =>
      onClick = => @onItemClick tag, index
      className = classnames 'item',
        'is-active': (index is current)
      div key: tag.get('_id'), className: className, onClick: onClick,
        tag.get('name')

  render: ->
    tags = query.tagsBy(recorder.getState(), @props._teamId) or Immutable.List()
    tag = tags.find (tag) => tag.get('_id') is @props._tagId
    if @props.hasTag
      defaultText = l('all-tags')
    else
      defaultText = l('no-tag-filter')

    itemAllClass = classnames 'item',
      'is-active': (@state.query.length is 0) and (@state.index is 0)
    itemAllTagClass = classnames 'item',
      'is-active': (@state.query.length is 0) and (@state.index is 1)

    LightDropdown
      displayText: tag?.get('name') or undefined
      defaultText: defaultText
      name: 'filter-tag'
      show: @state.showMenu
      onToggle: @onMenuToggle
      input
        className: 'query', value: @state.query, autoFocus: true, type: 'text'
        onChange: @onQueryChange, onClick: @onInputClick, onKeyDown: @onKeyDown
      div ref: 'scroll', className: 'results scroll thin-scroll',
        if @state.query.length is 0
          div null,
            div className: itemAllClass, onClick: @onAllClick, l('no-tag-filter')
            div className: itemAllTagClass, onClick: @onAllTagClick, l('all-tags')
            if @getListLength() > 2
              hr className: 'divider'
        @renderTags()
