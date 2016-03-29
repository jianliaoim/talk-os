React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div = React.createFactory 'div'

T = React.PropTypes
cx = require 'classnames'
zeroRect = top: 0, bottom: 0, left: 0, right: 0

module.exports = React.createClass
  displayName: 'light-menu'
  mixins: [PureRenderMixin]

  propTypes:
    # this components expects children
    hint: T.node.isRequired
    open: T.bool.isRequired
    onMenuToggle: T.func

  getDefaultProps: ->
    onMenuShow: (->)

  componentDidMount: ->
    window.addEventListener 'click', @onWindowClick
    @_rootEl = @refs.root

  componentWillUnmount: ->
    window.removeEventListener 'click', @onWindowClick

  getRootPosition: ->
    if @props.open and @_rootEl?
      @_rootEl.getBoundingClientRect()
    else
      zeroRect

  onWindowClick: ->
    if @props.open
      @props.onMenuToggle()

  onHintClick: (event) ->
    event.stopPropagation()
    @props.onMenuToggle()

  onMenuClick: (event) ->
    event.stopPropagation()
    @props.onMenuToggle()

  render: ->
    reachBottom = (window.innerHeight - @getRootPosition().bottom) < 370
    reachLeft = @getRootPosition().left < 400
    className = cx
      'light-menu': true
      'is-open': @props.open
      'is-reached-bottom': reachBottom
      'is-reached-left': reachLeft

    div ref: 'root', className: className,
      div className: 'hint', onClick: @onHintClick, @props.hint
      if @props.open
        div className: 'menu', onClick: @onMenuClick,
          @props.children
