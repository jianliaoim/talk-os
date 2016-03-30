React = require 'react'
classnames = require 'classnames'
keycode = require 'keycode'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'
mixinQuery = require '../mixin/query'

contactActions = require '../actions/contact'

search = require '../util/search'
orders = require '../util/orders'
dom = require '../util/dom'

LightDropdown = React.createFactory require '../module/light-dropdown'
UserAlias = React.createFactory require './user-alias'

div   = React.createFactory 'div'
input = React.createFactory 'input'
hr    = React.createFactory 'hr'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'filter-contact'

  mixins: [PureRenderMixin, mixinQuery]

  propTypes:
    _teamId: T.string.isRequired
    _creatorId: T.string
    onChange: T.func.isRequired

  componentDidMount: ->
    # bad idea to send actions in lifecycle
    contactActions.fetchLeftContacts @props._teamId
    @setState index: @getDefaultIndex()

  componentDidUpdate: ->
    @handleScroll()

  getInitialState: ->
    query: ''
    index: 0
    showMenu: false

  # user methods

  getDefaultIndex: ->
    if @props._creatorId
      (@getSortedContacts().findIndex (contact) => contact.get('_id') is @props._creatorId) + 1
    else
      0

  getSortedContacts: ->
    currentContacts = query.orList(query.contactsBy recorder.getState(), @props._teamId)
    leftContacts = query.orList(query.leftContactsBy recorder.getState(), @props._teamId)
    contacts = currentContacts.concat(leftContacts)
    contacts = search.forMembers contacts, @state.query, getAlias: @getContactAlias
    return contacts
    .sort orders.byPinyin
    .sort (a, b) ->
      switch
        when (not a.get('isQuit')) and b.get('isQuit') then -1
        when a.get('isQuit') and (not b.get('isQuit')) then 1
        else 0

  getListLength: ->
    length = @getSortedContacts().size
    if @state.query.length is 0
      length += 1
    length

  handleScroll: ->
    unless @refs.scroll?
      return
    each = 40
    scrollEl = @refs.scroll
    totalHeight = scrollEl.clientHeight
    top = scrollEl.scrollTop

    if @state.query.length > 0
      current = @state.index
    else
      current = @state.index + 1

    startY = current * each

    if (startY - top < 0) or ((startY + each) - top > totalHeight)
      y = startY - (totalHeight / 2)
      dom.smoothScrollTo scrollEl, 0, y

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
    contacts = @getSortedContacts()
    if (@state.query.length is 0)
      if @state.index is 0
        @props.onChange undefined
      else
        current = @state.index - 1
        contact = contacts.get(current)
        @props.onChange contact.get('_id')
    else
      contacts = @getSortedContacts()
      contact = contacts.get(@state.index)
      if contact?
        @props.onChange contact.get('_id')
    @onMenuToggle()

  # handle events

  onQueryChange: (event) ->
    @setState query: event.target.value.trim(), index: 0

  onInputClick: (event) ->
    event.stopPropagation()

  onItemClick: (contact, index) ->
    @props.onChange contact.get('_id')
    if @state.query.length > 0
      @setState index: index
    else
      @setState index: index + 1

  onAllClick: ->
    @props.onChange undefined
    @setState index: 0

  onKeyDown: (event) ->
    switch (keycode event.keyCode)
      when 'up' then @moveUp()
      when 'down' then @moveDown()
      when 'enter' then @selectCurrent()

  onMenuToggle: ->
    index = @getDefaultIndex()
    @setState
      index: index
      showMenu: not @state.showMenu

  # render views

  renderContacts: ->
    contacts = @getSortedContacts()
    if @state.query.length > 0
      current = @state.index
    else
      current = @state.index - 1
    contacts.map (contact, index) =>
      isQuit = if contact.get('isQuit') then "(#{lang.getText('contact-quitted')})"  else ''
      onClick = => @onItemClick contact, index
      className = classnames 'item', 'contact',
        'is-active': current is index
        'is-quit': contact.get('isQuit')
      div key: contact.get('_id'), className: className, onClick: onClick,
        UserAlias _teamId: @props._teamId, _userId: contact.get('_id'), defaultName: contact.get('name')
        "#{isQuit}"

  render: ->
    contact = query.requestContactsByOne(recorder.getState(), @props._teamId, @props._creatorId)

    LightDropdown
      displayText: contact?.get('name') or undefined
      defaultText: lang.getText('all-members')
      name: 'filter-contact'
      show: @state.showMenu
      onToggle: @onMenuToggle
      input
        className: 'query', value: @state.query, autoFocus: true, type: 'text'
        onChange: @onQueryChange, onClick: @onInputClick, onKeyDown: @onKeyDown
      div ref: 'scroll', className: 'scroll thin-scroll',
        if @state.query.length is 0
          className = classnames 'item', 'is-active': @state.index is 0
          div className: className, onClick: @onAllClick, lang.getText('all-members')
        @renderContacts()
