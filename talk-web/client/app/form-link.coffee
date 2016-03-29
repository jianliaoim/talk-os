cx = require 'classnames'
React = require 'react'
assign = require 'object-assign'
debounce = require 'debounce'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

notifyActions = require '../actions/notify'
discoverActions = require '../actions/discover'

lang = require '../locales/lang'

util = require '../util/util'

Icon = React.createFactory require '../module/icon'
LiteLoadingCircle = React.createFactory require('react-lite-misc').LoadingCircle

{ div, form, span, input, fieldset, noscript, textarea } = React.DOM
T = React.PropTypes

protoData =
  url: ''
  text: ''
  title: ''

module.exports = React.createClass
  displayName: 'form-link'

  propTypes:
    data: T.instanceOf(Immutable.Map)
    onChange: T.func
    onSubmit: T.func
    readOnly: T.bool
    willSubmit: T.bool
    displayMode: T.oneOf([ 'create', 'edit' ]).isRequired

  getDefaultProps: ->
    onChange: (->)
    onSubmit: (->)
    readOnly: false
    willSubmit: false

  getInitialState: ->
    data: @props.data or Immutable.Map protoData
    isDiscovered: @props.data?
    isDiscovering: false

  componentDidMount: ->
    @_onDiscover = debounce @onDiscover, 1000

    if @props.displayMode is 'edit'
      @setState
        isDiscovered: true

  componentWillReceiveProps: (nextProps) ->
    if not @props.willSubmit and nextProps.willSubmit
      @props.onSubmit @state.data

    if not nextProps.data?
      @setState
        data: Immutable.Map protoData
        isDiscovered: false

    if @props.displayMode is 'edit'
      if not @props.readOnly and nextProps.readOnly
        @setState
          data: @props.data or Immutable.Map protoData

  componentWillUnmount: ->
    @_onDiscover = null

  handleTextChange: (event) ->
    @willChange 'text', event.target.value

  handelTitleChange: (event) ->
    @willChange 'title', event.target.value

  handelURLChange: (event) ->
    @willChange 'url', event.target.value
    if @props.displayMode is 'create'
      @_onDiscover event.target.value.trim()

  willChange: (key, value) ->
    newState =
      data: @state.data.set key, value

    @setState newState
    if @state.isDiscovered
      @props.onChange newState.data

  onDiscover: (url) ->
    if not @isMounted()
      return

    if not (url.trim().length and util.isUrl url)
      return

    setState = (data) =>
      newState = assign {},
        data: Immutable.Map(data) if data?
        isDiscovered: true
        isDiscovering: false

      @setState newState
      if data?
        @props.onChange newState.data

    @setState
      isDiscovering: true
    , ->
      discoverActions
      .urlmeta url
      , (resp) ->
        resp.url = url
        setState resp
      , (error) ->
        setState()
        notifyActions.error lang.getText('read-link-failure')

  onFormSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit @state.data

  render: ->
    form className: cx('form-table', 'is-dashed': not @state.isDiscovered), onSubmit: @onFormSubmit,
      fieldset {},
        div className: 'form-row flex-horiz',
          if @state.isDiscovering
            span className: 'loading-circle flex-static',
              LiteLoadingCircle
                size: 14
          else if @state.data.get('faviconUrl')?.length > 0
            span className: 'image-box is-favicon flex-static', style: backgroundImage: "url(#{ @state.data.get 'faviconUrl' })"
          else noscript()
          input
            type: 'text'
            value: @state.data.get('url') or ''
            onChange: @handelURLChange
            readOnly: @props.readOnly
            autoFocus: @props.displayMode is 'create'
            className: 'text-row font-normal text-overflow'
            placeholder: if not @props.readOnly then lang.getText('share-link-title-placeholder')
        div className: 'form-row', hidden: not @state.isDiscovered,
          input
            type: 'text'
            value: @state.data.get('title') or ''
            onChange: @handelTitleChange
            readOnly: @props.readOnly
            autoFocus: not @props.readOnly
            className: 'text-row font-large text-overflow'
            placeholder: if not @props.readOnly then lang.getText 'placeholder-enter-title'
        div className: 'form-row flex-horiz', hidden: not @state.isDiscovered,
          if @state.data.get('imageUrl')?.length > 0
            span className: 'image-box is-pic flex-static', style: backgroundImage: "url(#{ @state.data.get 'imageUrl' })"
          else noscript()
          textarea
            value: @state.data.get('text') or ''
            onChange: @handleTextChange
            readOnly: @props.readOnly
            className: (cx 'textarea-row font-normal', 'is-resized': @state.data.get('imageUrl')?.length > 0)
            placeholder: if not @props.readOnly then lang.getText 'placeholder-enter-desc'
