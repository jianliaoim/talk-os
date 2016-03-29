# Code mostly done at:
# http://stackoverflow.com/a/26789089/883571

React = require 'react'
ReactDOM = require 'react-dom'

util = require '../util/util'
time = require '../util/time'

module.exports =

  # needs to implement

  # renderLayer: (afterTransition) ->
  # use afterTransition to control initial animation

  # bindWindowEvents: ->

  componentWillUnmount: ->
    return unless @_target?
    @_unrenderLayer()
    document.body.removeChild @_target
    @unbindWindowEvents?()

  componentDidUpdate: ->
    @_renderLayer()

  _renderLayer: ->
    if @_target?
      @_renderChildren()
      return
    if (not @props.show) and (not @_target?)
      return
    # so show but found no target
    @_target = document.createElement 'div'
    document.body.appendChild @_target
    @bindWindowEvents?()
    tree = @renderLayer false
    ReactDOM.render tree, @_target

    # use delay to create transition
    # more delay to fix in safari
    browser = util.parseUA().browser
    time.delay (if browser is 'safari' then 20 else 0), =>
      @_renderChildren()

  _renderChildren: ->
    tree = @renderLayer true
    ReactDOM.render tree, @_target

  _unrenderLayer: ->
    ReactDOM.unmountComponentAtNode @_target
