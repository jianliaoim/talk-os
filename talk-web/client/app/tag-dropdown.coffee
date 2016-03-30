cx     = require 'classnames'
React  = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
messageActions = require '../actions/message'
tagActions     = require '../actions/tag'

mixinSubscribe = require '../mixin/subscribe'

lang     = require '../locales/lang'

keyboard = require '../util/keyboard'
orders   = require '../util/orders'
search   = require '../util/search'
dom      = require '../util/dom'

div  = React.createFactory 'div'
input  = React.createFactory 'input'
span = React.createFactory 'span'

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'tag-dropdown'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    tags:       T.instanceOf(Immutable.List)
    _messageId: T.string.isRequired
    _teamId:    T.string.isRequired

  getInitialState: ->
    tags: @getTeamTags()
    index: -1

  componentDidMount: ->
    @_inputEl = @refs.input
    @subscribe recorder, => @setState tags: @getTeamTags()

  componentDidUpdate: ->
    @handleScroll()

  getTeamTags: ->
    _teamId = @props._teamId
    query.tagsBy(recorder.getState(), _teamId) or Immutable.List()

  handleScroll: ->
    unless @refs.scroll?
      return
    each = 34
    scrollEl = @refs.scroll

    totalHeight = scrollEl.clientHeight
    top = scrollEl.scrollTop

    current = @state.index

    startY = current * each

    if ((startY - top) < 0) or ((startY + each) - top > totalHeight)
      y = startY - totalHeight / 2
      dom.smoothScrollTo scrollEl, 0, y

  selectPrev: ->
    if @state.index > -1
      @setState index: @state.index - 1

  selectNext: ->
    if @state.index < @state.tags.size - 1
      @setState index: @state.index + 1
    else
      @setState index: 0

  onTagAdd: ->
    # TODO, bad idea to read value from DOM, use state instead
    value = @_inputEl.value
    teamTags = @getTeamTags()
    tags = @props.tags or Immutable.List()

    if @state.index isnt -1
      _tagId = @state.tags.get(@state.index).get('_id')
      @onTagClick _tagId, @state.index
    else if value.replace(/\s/g, '').length isnt 0
      if teamTags.map((tag) -> tag.get('name')).contains(value)
        if not @props.tags.map((tag) -> tag.get('name')).contains(value)
          #bind exited tag
          teamTags.map (tag) ->
            if tag.get('name') is value
              tags = tags.push tag
          _tagIds = tags.map((tag) -> tag.get('_id')).toJS()
          data = {_tagIds}
          messageActions.messageUpdate @props._messageId, data
      else
        #create tag
        tagActions.createTag @props._teamId, value, (resp) =>
          tags = tags.push Immutable.fromJS(resp)
          _tagIds = tags.map((tag) -> tag.get('_id')).toJS()
          data = {_tagIds}
          messageActions.messageUpdate @props._messageId, data
      @_inputEl.value = ''

  onInputChange: (event) ->
    filterTags = search.forTags @getTeamTags(), event.target.value
    @setState tags: filterTags, index: -1

  onTagClick: (_tagId, index) ->
    tags = @props.tags or Immutable.List()
    tagIds = tags.map (tag) -> tag.get('_id')
    tagExited = tagIds.contains(_tagId)
    if tagExited
      data =
        _tagIds: tagIds.filter((id) -> id isnt _tagId).toJS()
      messageActions.messageUpdate @props._messageId, data
    else
      data =
        _tagIds: tagIds.push(_tagId).toJS()
      messageActions.messageUpdate @props._messageId, data
    @_inputEl.focus()
    @setState index: index

  onKeyDown: (event) ->
    switch event.keyCode
      when keyboard.enter then @onTagAdd()
      when keyboard.up then @selectPrev()
      when keyboard.down then @selectNext()

  renderHeader: ->
    div className: 'header line',
      input
        ref: 'input', type: 'text', autoFocus: true
        className: 'input form-control', placeholder: l('enter-tag-name')
        onChange: @onInputChange, onKeyDown: @onKeyDown
      span className: 'add', onClick: @onTagAdd,
        l('add')

  renderTags: ->
    tags = @props.tags or []
    tagIds = tags.map((tag) -> tag.get('_id'))
    div className: 'tags',
      @state.tags
      .sort (a, b) ->
        orders.isTagActive a, b, tagIds
      .map (tag, index) =>
        onTagClick = => @onTagClick tag.get('_id'), index
        className = cx 'flex-horiz', 'item', 'rich-line', 'is-selected': index is @state.index
        tagClassName = cx 'ti', 'ti-tick',
          'is-active': tagIds.contains(tag.get('_id'))

        div key: tag.get('_id'), className: className, onClick: onTagClick,
          span className: 'name', tag.get('name')
          span className: tagClassName

  render: ->
    div className: 'tag-dropdown',
      @renderHeader()
      div className: 'thin-scroll', ref: 'scroll',
        @renderTags()
