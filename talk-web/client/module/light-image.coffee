React = require 'react'
classnames = require 'classnames'

{div, span, img, i} = React.DOM

module.exports = React.createClass
  displayName: 'light-image'

  propTypes:
    onClick: React.PropTypes.func
    onLoaded: React.PropTypes.func
    src: React.PropTypes.string.isRequired
    width: React.PropTypes.number
    height: React.PropTypes.number
    style: React.PropTypes.object

  getDetaultProps: ->
    width: 'auto'
    height: 'auto'

  getInitialState: ->
    stage: 'loading'

  componentDidMount: ->
    @loadImage @props.src

  componentWillReceiveProps: (props) ->
    if props.src isnt @props.src
      @loadImage props.src

  # methods

  loadImage: (src) ->
    isDataUri = @props.src.substring(0, 4) is 'data'
    if isDataUri
      @loadDataUrl src
    else
      @loadRemoteImage src

  loadRemoteImage: (src) ->
    @setState stage: 'loading'
    @imgEl = document.createElement 'img'
    @imgEl.onload = @onImageLoad
    @imgEl.onerror = @onImageError
    @imgEl.src = src

  loadDataUrl: (src) ->
    @setState stage: 'done'

  destroyImage: ->
    if @imgEl
      @imgEl.onload = null
      @imgEl.onerror = null
      @imgEl = null

  # internal event

  onImageLoad: (event) ->
    if @isMounted()
      @setState stage: 'done'
      @onLoaded()
    @destroyImage()

  onImageError: (event) ->
    @setState stage: 'error'
    @destroyImage()

  # external events

  onClick: (event) ->
    event.stopPropagation()
    @props.onClick?()

  onLoaded: ->
    @props.onLoaded?()

  onReloadImage: (event) ->
    @setState stage: 'loading'
    @loadImage @props.src

  # renderers

  renderLoading: ->
    className = classnames 'loading-layer',
      'is-active': @state.stage is 'loading'

    div className: className,
      div className: 'image-spinner',
        div className: 'cube1'
        div className: 'cube2'

  renderImage: ->
    className = classnames 'image-layer',
      'is-active': @state.stage is 'done'
    style =
      width: @props.width
      height: @props.height

    img className: className, src: @props.src, onClick: @onClick, style: style

  renderError: ->
    className = classnames 'error-layer',
      'is-active': @state.stage is 'error'

    div className: className,
      i className: 'image-reloader ti ti-refresh', onClick: @onReloadImage

  render: ->
    style = @props.style or {}
    style.width = @props.width
    style.height = @props.height

    div className: 'light-image', style: style,
      @renderLoading()
      @renderError()
      @renderImage()
