React = require 'react'
debounce = require 'debounce'
Immutable = require 'immutable'

lang = require '../locales/lang'

LiteLoadingCircle = React.createFactory require('react-lite-misc').LoadingCircle

{a, div, span} = React.DOM

module.exports = React.createClass

  propTypes:
    stage: React.PropTypes.instanceOf(Immutable.List).isRequired
    isEmpty: React.PropTypes.bool.isRequired
    children: React.PropTypes.any.isRequired
    onRequestAfter: React.PropTypes.func.isRequired
    onRequestBefore: React.PropTypes.func.isRequired

  componentDidMount: ->
    @debouncedOnRequestAfter = debounce @props.onRequestAfter, 400
    @debouncedOnRequestBefore = debounce @props.onRequestBefore, 400

  onClickBottom: ->
    return if @props.stage is 'complete'
    @props.onRequestAfter()

  onClickTop: ->
    return if @props.stage is 'complete'
    @props.onRequestBefore()

  onScroll: (event) ->
    target = event.target

    if target.scrollTop < 10
      @debouncedOnRequestBefore()
    else if target.scrollTop + target.clientHeight + 10 > target.scrollHeight
      @debouncedOnRequestAfter()

  render: ->
    div className: 'activity-container thin-scroll', onScroll: @onScroll,
      div className: 'overview-loading',
        switch @props.stage.first()
          when 'loading'
            LiteLoadingCircle size: 24
          when 'partial'
            a className: 'muted', onClick: @onClickTop,
              lang.getText('load-more')
      @props.children
      div className: 'overview-loading',
        switch @props.stage.last()
          when 'loading'
            LiteLoadingCircle size: 24
          when 'partial'
            a className: 'muted', onClick: @onClickBottom,
              lang.getText('load-more')
          else
            if @props.isEmpty
              span className: 'muted', lang.getText('no-activities-yet')
