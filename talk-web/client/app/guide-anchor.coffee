React   = require 'react'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang = require '../locales/lang'

config = require '../config'
eventBus = require '../event-bus'

prefsActions = require '../actions/prefs'

LitePopover = React.createFactory require 'react-lite-layered/lib/popover'
GuideCircle = React.createFactory require '../app/guide-circle'

div  = React.createFactory 'div'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'guide-anchor'
  mixins: [PureRenderMixin]

  propTypes:
    title:    T.string.isRequired
    content:  T.string

  getInitialState: ->
    prefs = query.prefs(recorder.getState())
    showCard: false
    hasShownTips: prefs?.get('hasShownTips') or false

  componentDidMount: ->
    @_rootEl = @refs.root
    eventBus.addListener 'dirty-action/show-guide', @setShowCard

  componentWillUnmount: ->
    eventBus.removeListener 'dirty-action/show-guide', @setShowCard

  setShowCard: ->
    @setState hasShownTips: false

  getBaseArea: ->
    if @_rootEl?
      @_rootEl.getBoundingClientRect()
    else
      {}

  onCardHide: ->
    @setState hasShownTips: true, showCard: false

  onCircleClick: ->
    unless @state.hasShownTips
      prefsActions.prefsUpdate hasShownTips: true
      prefsActions.silentUpdate hasShownTips: true
    @setState showCard: true

  renderCard: ->
    LitePopover
      title: lang.getText(@props.title)
      showClose: true
      baseArea: if @state.showCard then @getBaseArea() else {}
      onPopoverClose: @onCardHide
      show: @state.showCard
      name: 'guide-anchor'
      div className: 'guide-content', lang.getText(@props.content)

  render: ->
    if config.isGuest
      return span()

    div ref: 'root', className: 'guide-anchor',
      if (not @state.hasShownTips) or @state.showCard
        GuideCircle onClick: @onCircleClick
      @renderCard()
