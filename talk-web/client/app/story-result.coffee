cx = require 'classnames'
React = require 'react'
debounce = require 'debounce'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

colors = require '../util/colors'
lang = require '../locales/lang'

StoryViewer = React.createFactory require './story-viewer'
RelativeTime = React.createFactory require '../module/relative-time'
Avatar = React.createFactory require '../module/avatar'
LightModalBeta = React.createFactory require '../module/light-modal'

{ div, span } = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'story-result'
  mixins: [PureRenderMixin]

  propTypes:
    story: T.instanceOf(Immutable.Map).isRequired
    onClick: T.func

  getInitialState: ->
    showStoryViewer: false

  onStoryClick: (event) ->
    event.stopPropagation()
    @setState showStoryViewer: true

  onStoryViewerClose: ->
    @setState showStoryViewer: false

  renderStoryViewer: ->
    LightModalBeta
      name: 'story-viewer'
      show: @state.showStoryViewer
      onCloseClick: @onStoryViewerClose
      StoryViewer
        story: @props.story
        onClose: @onStoryViewerClose

  renderThumbnail: ->
    category = @props.story.get('category')
    data = @props.story.get('data')

    cxAvatar = ['avatar', 'large', 'round']

    switch category
      when 'file'
        className = cx cxAvatar
        text = data.get 'fileType'
      when 'link'
        className = cx cxAvatar, 'ti', 'ti-chain'
      when 'topic'
        className = cx cxAvatar, 'ti', 'ti-sharp'

    style =
      backgroundColor: colors['files'][data.get 'fileType'] or colors['story'][category]

    onClick = if category is 'file' then @onStoryClick else ( -> )

    span className: className, style: style, onClick: onClick, text

  renderBody: ->
    div className: 'body flex-vert',
      span className: 'title bold', @props.story.get('title')
      span className: 'author muted', @props.story.getIn(['creator', 'name'])

  render: ->
    div className: 'story-result rich-line flex-horiz', onClick: @props.onClick,
      @renderThumbnail()
      @renderBody()
      @renderStoryViewer()
