cx = require 'classnames'
React = require 'react'

lang = require '../locales/lang'
time = require '../util/time'

Avatar = React.createFactory require '../module/avatar'

{ h4, div, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'creator-info'

  propTypes:
    name: T.string
    avatarUrl: T.string
    className: T.string
    createTime: T.string

  getDefaultProps: ->
    name: ''
    avatarUrl: ''

  render: ->
    div className: cx('creator-info', @props.className),
      Avatar src: @props.avatarUrl, size: 'normal', shape: 'round'
      h4 className: 'name text-overflow', @props.name
      h4 className: 'time text-overflow', time.createTime @props.createTime
