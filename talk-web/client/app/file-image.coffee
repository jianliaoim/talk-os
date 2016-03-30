React = require 'react'
cx = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
util = require '../util/util'
analytics = require '../util/analytics'

LightOverlay  = React.createFactory require '../module/light-overlay'
LightImage = React.createFactory require '../module/light-image'
Icon = React.createFactory require '../module/icon'

div = React.createFactory 'div'
img = React.createFactory 'img'
span = React.createFactory 'span'

degs = [0, 90, 180, 270, 360]

module.exports = React.createClass
  displayName: 'file-image'
  mixins: [PureRenderMixin]

  propTypes:
    file: React.PropTypes.object.isRequired

  getInitialState: ->
    showLarge: false
    currentIndex: 0
    scale: 1
    quiet: false

  componentDidMount: ->
    @container = @refs.container
    window.addEventListener 'resize', @onWindowResize

  componentWillUnmount: ->
    window.addEventListener 'resize', @onWindowResize

  calculateScale: (index) ->
    iWidth = @props.file.get('imageWidth')
    iHeight = @props.file.get('imageHeight')
    cWidth = @container.clientWidth
    cHeight = @container.clientHeight

    if index % 2 is 0
      1
    else
      util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)

  onWindowResize: ->
    if @isMounted()
      @setState
        scale: @calculateScale(@state.currentIndex)

  onZoomIn: ->
    analytics.viewOverlayImage()
    @setState showLarge: true

  onZoomClose: (event) ->
    event.stopPropagation()
    @setState showLarge: false

  updateIndex: (index) ->
    @setState
      currentIndex: index
      scale: @calculateScale(index)
      quiet: false

  onRotate: (moveIndex, rotateLeft) ->
    nextIndex =  (@state.currentIndex + moveIndex) % degs.length

    reachLeft = -> nextIndex is (degs.length - 1) and rotateLeft
    reachRight= -> nextIndex is 0 and not rotateLeft

    if reachLeft()
      @setState
        quiet: true
        currentIndex: nextIndex
        , => @updateIndex(nextIndex - 1)
    else if reachRight()
      @setState
        quiet: true
        currentIndex: nextIndex
        , => @updateIndex(nextIndex + 1)
    else
      @updateIndex(nextIndex)

  renderRotateBar: ->
    onRotateLeft = => @onRotate(degs.length - 1, true)
    onRotateRight = => @onRotate(1, false)

    div className: 'rotate-bar flex-horiz flex-vcenter',
      div className: 'line flex-horiz flex-vcenter', onClick: onRotateLeft,
        Icon name: 'rotate-left', size: 20
        lang.getText('rotate-left')
      div className: 'line flex-horiz flex-vcenter', onClick: onRotateRight,
        Icon name: 'rotate-right', size: 20
        lang.getText('rotate-right')

  render: ->
    src = @props.file.get('downloadUrl')

    largePic = @props.file.get('imageHeight') > window.innerHeight and @props.file.get('imageWidth') > window.innerWidth
    imgClassName = cx 'is-full', {'is-large': largePic}
    className = cx 'file-image', "rotate-#{degs[@state.currentIndex]}", 'animate': not @state.quiet

    style =
      WebkitTransform: "scale(#{@state.scale})"
      transform: "scale(#{@state.scale})"

    div className: className,
      div className: 'image-container', ref: 'container',
        @renderRotateBar()
        LightImage src: src, style: style, onClick: @onZoomIn
        LightOverlay show: @state.showLarge, name: 'file-image',
          img
            className: imgClassName
            src: @props.file.get('downloadUrl'), onClick: @onZoomClose
