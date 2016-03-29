React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

recorder = require 'actions-recorder'
lang = require '../locales/lang'

query = require '../query'
emojiUtil = require '../util//emoji'
emojisCategory = require '../util/emojis-category'

LiteSwitchTabs = React.createFactory require('react-lite-misc').SwitchTabs

{div, span, a, ul, li} = React.DOM

T = React.PropTypes
cx = require 'classnames'

categories = ['people', 'nature', 'objects', 'places', 'symbols']

module.exports = React.createClass
  displayName: 'emoji-table'
  mixins: [PureRenderMixin]

  propTypes:
    onSelect: T.func.isRequired

  getInitialState: ->
    page: 'people'
    preview: emojisCategory['people'][0]

  # methods

  # events

  onTabClick: (tab) ->
    @setState page: tab
    @setState preview: emojisCategory[tab][0]

  onSelect: (emoji) ->
    @props.onSelect emoji

  onClick: (event) ->
    event.stopPropagation()

  onPreview: (emoji) ->
    @setState preview: emoji

  # render

  renderTabs: ->
    LiteSwitchTabs
      data: categories, tab: @state.page
      getText: lang.getText
      onTabClick: @onTabClick

  renderEmoji: (emoji) ->
    onClick = =>
      @onSelect emoji
    onMouseEnter = =>
      @onPreview emoji

    li
      key: emoji
      className: 'emoji-container'
      onClick: onClick
      onMouseEnter: onMouseEnter
      dangerouslySetInnerHTML: __html: emojiUtil.replace(":#{emoji}:")

  renderEmojis: ->
    emojis = emojisCategory[@state.page]
    ul className: 'emojis thin-scroll',
      emojis.map @renderEmoji

  renderFooter: ->
    div className: 'footer',
      @renderPreview()
      @renderMostUsed()

  renderPreview: ->
    emoji = @state.preview
    div className: 'emoji-preview',
      span dangerouslySetInnerHTML: __html: emojiUtil.replace(":#{emoji}:")
      span className: 'word',
        ":#{emoji}:"

  renderMostUsed: ->
    emojis = query.mostRecentEmojis(recorder.getState())
    ul className: 'emoji-most-used',
      emojis.map @renderEmoji

  render: ->

    div className: 'emoji-table', onClick: @onClick,
      @renderTabs()
      @renderEmojis()
      @renderFooter()
