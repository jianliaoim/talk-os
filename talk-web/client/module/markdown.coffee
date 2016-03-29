cx = require 'classnames'
React = require 'react'
MarkdownIt = require 'markdown-it'
MarkdownItEmoji = require 'markdown-it-emoji/light'
MarkdownItAttrs = require 'markdown-it-attrs'
PureRenderMixin = require 'react-addons-pure-render-mixin'

emojiUtil = require '../util/emoji'
emojisList = require('../util/emojis-list').reduce (obj, e) ->
  obj[e] = e
  obj
, {}

{ div } = React.DOM
T = React.PropTypes

markdown = new MarkdownIt()
  .set
    linkify: true
    typographer: true
    breaks: true
  .use MarkdownItEmoji,
    defs: emojisList
    shortcuts: {}
  .use MarkdownItAttrs
  .disable 'image'

markdown.renderer.rules.emoji = (token, idx) ->
  emojiUtil.toElement token[idx].markup

module.exports = React.createClass
  displayName: 'markdown'

  mixins: [PureRenderMixin]

  propTypes:
    value: T.string

  getDefaultProps: ->
    value: ''

  render: ->
    div
      className: 'markdown-body'
      dangerouslySetInnerHTML:
        __html: markdown.render(@props.value)
