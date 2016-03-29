
React = require 'react'
Immutable = require 'immutable'
classnames = require 'classnames'

ajax = require '../ajax'
detect = require '../util/detect'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'

areaNumbers = [
  ['cn', '+86']
  ['hk', '+852']
  ['tw', '+886']
  ['jp', '+81']
  ['usa', '+1']
]

arrayFind = (list, callback) ->
  if list.length > 0
    firstItem = list[0]
    restItems = list.slice 1
    matched = callback firstItem
    if matched
      firstItem
    else
      arrayFind restItems, callback
  else
    null

{div, input, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'reset-password'

  propTypes:
    account: React.PropTypes.string.isRequired
    language: React.PropTypes.string.isRequired
    onChange: React.PropTypes.func.isRequired
    autoFocus: React.PropTypes.bool

  getDefaultProps: ->
    autoFocus: false

  getInitialState: ->
    showMenu: false
    isFocused: false

  componentDidMount: ->
    window.addEventListener 'click', @onOutsideClick

  componentWillUnmount: ->
    window.removeEventListener 'click', @onOutsideClick

  onOutsideClick: ->
    if @state.showMenu
      @setState showMenu: false

  readAccount: ->
    if @props.account[0] is '+'
      targetArea = arrayFind areaNumbers, (pair) =>
        @props.account.indexOf(pair[1]) is 0
      if targetArea
        area: targetArea[0]
        areaNumber: targetArea[1]
        number: @props.account.slice targetArea[1].length
      else
        area: 'other'
        areaNumber: ''
        number: @props.account
    else
      area: 'other'
      areaNumber: ''
      number: @props.account

  onAreaClick: (event) ->
    event.stopPropagation()
    @setState showMenu: true

  onAreaItemClick: (area) ->
    details = @readAccount()
    if area in ['cn', 'hk', 'tw', 'jp', 'usa']
      targetArea = arrayFind areaNumbers, (pair) ->
        pair[0] is area
      @props.onChange "#{targetArea[1]}#{details.number}"
    else
      @props.onChange "#{details.number}"

  onNumberChange: (event) ->
    text = event.target.value
    if text[0] is '+'
      @props.onChange text
    else
      details = @readAccount()
      @props.onChange "#{details.areaNumber}#{text}"

  onFocus: ->
    @setState isFocused: true

  onBlur: ->
    @setState isFocused: false

  renderMenu: ->
    onOtherClick = =>
      @onAreaItemClick 'other'

    div className: 'area-menu',
      areaNumbers.map (pair) =>
        onClick = => @onAreaItemClick pair[0]
        div key: pair[0], className: 'area-item', onClick: onClick,
          span className: "area-icon is-#{pair[0]}"
          span className: 'area-number', pair[1]
      div className: 'area-item', onClick: onOtherClick,
        span className: "area-icon is-other"
        span className: 'area-number', locales.get('other', @props.language)

  render: ->
    details = @readAccount()
    className = classnames 'mobile-input',
      'is-focused': @state.isFocused

    div className: className,
      div className: 'area-part', onClick: @onAreaClick,
        details.areaNumber or locales.get('other', @props.language)
      input
        type: 'text', className: 'number-part',
        value: details.number, onChange: @onNumberChange
        placeholder: locales.get('phoneNumber', @props.language)
        onFocus: @onFocus, onBlur: @onBlur
        autoFocus: @props.autoFocus, name: 'phone'
      if @state.showMenu
        @renderMenu()
      if detect.isMobile(@props.account)
        span className: 'ok-icon icon icon-tick'
