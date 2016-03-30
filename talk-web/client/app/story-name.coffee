React = require 'react'

colors = require '../util/colors'

Icon = React.createFactory require '../module/icon'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'story-name'
  mixins: [PureRenderMixin]

  propTypes:
    title: T.string
    showIcon: T.bool
    category: T.oneOf(['file', 'link', 'topic']).isRequired

  getDefaultProps: ->
    title: ''
    showIcon: true

  renderIcon: ->
    return null unless @props.showIcon

    switch @props.category
      when 'file'
        icon = 'paperclip-lean'
      when 'link'
        icon = 'chain'
      when 'topic'
        icon = 'idea'

    Icon
      name: icon
      color: '#FFF'
      backgroundColor: colors.story[@props.category]

  render: ->
    div className: 'story-name',
      @renderIcon()
      span className: 'name text-overflow', @props.title
