React = require 'react'
Immutable = require 'immutable'
debounce = require 'debounce'
PureRenderMixin = require 'react-addons-pure-render-mixin'

keyboard = require '../util/keyboard'
dom      = require '../util/dom'

lang = require '../locales/lang'

ContactName = React.createFactory require '../app/contact-name'

div  = React.createFactory 'div'
span = React.createFactory 'span'
hr   = React.createFactory 'hr'

T = React.PropTypes

# show only 80 of total matches
limit80 = (x) ->
  if x > 80 then 80 else x

module.exports = React.createClass
  displayName: 'mention-menu'
  mixins: [PureRenderMixin]

  propTypes:
    members:  T.instanceOf(Immutable.List)
    contacts: T.instanceOf(Immutable.List)
    onSelect: T.func.isRequired
    _teamId: T.string.isRequired

  getInitialState: ->
    index: 0

  componentWillReceiveProps: (props) ->
    if props.members.size isnt @props.members.size
      @setState index: 0
    if props.contacts.size isnt @props.contacts.size
      @setState index: 0

  componentDidMount: ->
    @debouncedUpdateScroll = debounce @updateScroll, 50
    window.addEventListener 'keydown', @onWindowKeydown

  componentWillUnmount: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  componentDidUpdate: ->
    root = @refs.root
    @debouncedUpdateScroll(root)

  updateScroll: (root) ->
    eachHeight = 36
    HrHeight = 9
    totalHeight = eachHeight * 8
    startY = eachHeight * @state.index
    endY = startY + eachHeight
    top = root.scrollTop

    if @state.index > @props.members.size
      startY += HrHeight
      endY += HrHeight

    if (startY < top) or (endY > top + totalHeight)
      y = startY - (totalHeight / 2)
      dom.smoothScrollTo root, 0, y

  # methods

  getLength: ->
    @props.contacts.size + @props.members.size

  getMergedList: ->
    members = @props.members.sortBy (member) -> member.get('pinyin')
    contacts = @props.contacts.sortBy (member) -> member.get('pinyin')
    members.concat(contacts)

  moveSelectUp: ->
    if @getLength() < 2 then return
    if @state.index is 0
      @setState index: limit80(@getLength()) - 1
    else
      @setState index: (@state.index - 1)

  moveSelectDown: ->
    if @getLength() < 2 then return
    if (@state.index + 1) >= limit80(@getLength())
      @setState index: 0
    else
      @setState index: (@state.index + 1)

  selectCurrent: ->
    member = @getMergedList().get(@state.index)
    @props.onSelect member

  # event handlers

  onItemClick: (member) ->
    @props.onSelect member

  onWindowKeydown: (event) ->
    switch event.keyCode
      when keyboard.up then @moveSelectUp()
      when keyboard.down then @moveSelectDown()
      when keyboard.enter then @selectCurrent()
      when keyboard.tab then @selectCurrent()

  onSelect: (index) ->
    @setState {index}

  renderMembers: ->
    memberIds = @props.members
    .map (member) -> member.get('_id')
    .toJS()
    locale = lang.getText('no-in-topic')

    @getMergedList().map (member, index) =>
      onClick = =>
        @onItemClick member
      onMouseEnter = =>
        @onSelect index
      # isMember = memberIds.contains(member.get('_id'))
      # switch to native method for performance
      isMember = memberIds.indexOf(member.get('_id')) >= 0
      ContactName
        contact: member
        _teamId: @props._teamId
        key: member.get('_id')
        hover: @state.index is index
        online: true
        onClick: onClick
        showUnread: false
        onMouseEnter: onMouseEnter
        if (not isMember)
          span className: 'muted hint flex-static', locale

  render: ->
    memberElements = @renderMembers()
    pos = @props.members.size

    if (@props.members.size > 0) and (@props.contacts.size > 0)
      divider =  hr key: 'divider', className: 'divider'
      memberElements = memberElements[...pos].concat divider, memberElements[pos..]

    div className: 'mention-menu menu thin-scroll', ref: 'root',
      memberElements[...limit80(80)]
