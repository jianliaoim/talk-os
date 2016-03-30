React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'
ReactCSSTransitionGroup = React.createFactory require 'react-addons-css-transition-group'

recorder = require 'actions-recorder'
query = require '../query'
orders = require '../util/orders'
handlers = require '../handlers'
lang     = require '../locales/lang'

LightPopover = React.createFactory require '../module/light-popover'
Icon = React.createFactory require '../module/icon'

ContactName = React.createFactory require '../app/contact-name'

T = React.PropTypes
{ div, span }  = React.DOM

module.exports = React.createClass
  displayName: 'message-receipt-status'
  mixins: [PureRenderMixin]

  propTypes:
    message: T.instanceOf(Immutable.Map)

  getInitialState: ->
    showDropdown: false

  getDropdownBaseArea: ->
    if @state.showDropdown and @refs.root
      @refs.root.getBoundingClientRect()
    else
      {}

  onClick: (event) ->
    event.stopPropagation()
    @setState
      showDropdown: not @state.showDropdown

  onDropdownClose: ->
    @setState
      showDropdown: false

  positionAlgorithm: (area) ->
    if (area.left + 240) > window.innerWidth
      left = area.left - 220
    else
      left = area.left
    if (area.top + 320) > window.innerHeight
      left: area.left - 224
      bottom: window.innerHeight - area.top
    else
      left: area.left - 224
      top: area.bottom

  renderReceiptDropdown: ->
    LightPopover
      name: 'receipt-dropdown'
      onPopoverClose: @onDropdownClose
      positionAlgorithm: @positionAlgorithm
      baseArea: @getDropdownBaseArea()
      showClose: false
      show: @state.showDropdown
      @renderReceiptDropdownContent()

  renderReceiptDropdownContent: ->
    return null if not @state.showDropdown
    _teamId = @props.message.get('_teamId')
    contacts = query.contactsBy(recorder.getState(), _teamId)
    mentions = @props.message.get('mentions')
    receiptors = @props.message.get('receiptors')
    contacts = contacts
      .filter (contact) ->
        mentions.includes(contact.get('_id'))
      .sort orders.byPinyin
      .sortBy (contact) ->
        -receiptors.includes(contact.get('_id'))
      .map (contact) ->
        onClick = ->
          handlers.router.chat(_teamId, contact.get('_id'))
        ContactName
          key: contact.get('_id')
          contact: contact
          _teamId: _teamId
          onClick: onClick
          active: receiptors.includes(contact.get('_id'))

    div className: 'receipt-dropdown',
      div className: 'header',
        if mentions.size is receiptors.size
          lang.getText('read-by-all')
        else
          "#{lang.getText('read-by')} (#{receiptors.size}/#{mentions.size})"
      div className: 'thin-scroll',
        contacts

  render: ->
    return null if not @props.message

    mentions = @props.message.get('mentions') or Immutable.List()

    return null if mentions.size is 0

    _userId = query.userId(recorder.getState())
    _creatorId = @props.message.get('_creatorId')

    receiptors = @props.message.get('receiptors') or Immutable.List()
    isMentioned = mentions.includes(_userId)
    hasReadMessage = receiptors.includes(_userId)

    span ref: 'root', className: 'message-read-status',
      Icon
        size: 16
        name: 'tick-circle'
        className: 'muted'
        onClick: @onClick
      @renderReceiptDropdown()
