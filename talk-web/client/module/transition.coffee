# https://github.com/facebook/react/issues/1326
# compiled by JSX compiler and js2coffee
# rewrite to remove jQuery dependency

React = require 'react'
ReactDOM = require 'react-dom'

typeUtil = require '../util/type'

animationSupported = ->
  endEvents.length isnt 0

removeClass = (node, x) ->
  classList = node.className.split(' ')
  classList = classList.filter (name) -> name isnt x
  node.className = classList.join(' ')

addClass = (node, x) ->
  classList = node.className.split(' ')
  classList = classList.concat [x]
  node.className = classList.join(' ')

ReactTransitionGroup = require 'react-addons-transition-group'
TICK = 17
EVENT_NAME_MAP =
  transitionend:
    transition: "transitionend"
    WebkitTransition: "webkitTransitionEnd"
    MozTransition: "mozTransitionEnd"
    OTransition: "oTransitionEnd"
    msTransition: "MSTransitionEnd"

  animationend:
    animation: "animationend"
    WebkitAnimation: "webkitAnimationEnd"
    MozAnimation: "mozAnimationEnd"
    OAnimation: "oAnimationEnd"
    msAnimation: "MSAnimationEnd"

endEvents = []
detectEvents = do ->
  return if typeof window is 'undefined'
  testEl = document.createElement("div")
  style = testEl.style
  delete EVENT_NAME_MAP.animationend.animation  unless "AnimationEvent" of window
  delete EVENT_NAME_MAP.transitionend.transition  unless "TransitionEvent" of window
  for baseEventName of EVENT_NAME_MAP
    if EVENT_NAME_MAP.hasOwnProperty(baseEventName)
      baseEvents = EVENT_NAME_MAP[baseEventName]
      for styleName of baseEvents
        if styleName of style
          endEvents.push baseEvents[styleName]
          break

TimeoutTransitionGroupChild = React.createClass
  displayName: "TimeoutTransitionGroupChild"
  transition: (animationType, finishCallback) ->
    node = ReactDOM.findDOMNode(this)
    className = @props.name + "-" + animationType
    activeClassName = className + "-active"
    endListener = ->
      removeClass node, className
      removeClass node, activeClassName

      # Usually this optional callback is used for informing an owner of
      # a leave animation and telling it to remove the child.
      finishCallback and finishCallback()
      return

    unless animationSupported()
      endListener()
    else
      if animationType is "enter"
        @animationTimeout = setTimeout(endListener, @props.enterTimeout)
      else @animationTimeout = setTimeout(endListener, @props.leaveTimeout)  if animationType is "leave"
    addClass node, className

    # Need to do this to actually trigger a transition.
    @queueClass activeClassName
    return

  queueClass: (className) ->
    @classNameQueue.push className
    @timeout = setTimeout(@flushClassNameQueue, TICK)  unless @timeout
    return

  flushClassNameQueue: ->
    if @isMounted()
      addClass ReactDOM.findDOMNode(this), @classNameQueue.join(" ")
    @classNameQueue.length = 0
    @timeout = null
    return

  componentWillMount: ->
    @classNameQueue = []
    return

  componentWillUnmount: ->
    clearTimeout @timeout  if @timeout
    clearTimeout @animationTimeout  if @animationTimeout
    return

  componentWillEnter: (done) ->
    if @props.enter
      @transition "enter", done
    else
      done()
    return

  componentWillLeave: (done) ->
    if @props.leave
      @transition "leave", done
    else
      done()
    return

  render: ->
    React.Children.only @props.children

TimeoutTransitionGroup = React.createClass
  displayName: "TimeoutTransitionGroup"
  propTypes:
    enterTimeout: React.PropTypes.number.isRequired
    leaveTimeout: React.PropTypes.number.isRequired
    transitionName: React.PropTypes.string.isRequired
    transitionEnter: React.PropTypes.bool
    transitionLeave: React.PropTypes.bool

  getDefaultProps: ->
    transitionEnter: true
    transitionLeave: true

  _wrapChild: (child) ->
    React.createElement TimeoutTransitionGroupChild,
      enterTimeout: @props.enterTimeout
      leaveTimeout: @props.leaveTimeout
      name: @props.transitionName
      enter: @props.transitionEnter
      leave: @props.transitionLeave
    , child

  render: ->
    React.createElement ReactTransitionGroup, React.__spread({}, @props,
      childFactory: @_wrapChild
    )

module.exports = TimeoutTransitionGroup
