React = require 'react'
urlParse = require 'url-parse'
Immutable = require 'immutable'
cx = require 'classnames'

mixinChannelInfo = require '../mixin/channel-info'

constraint = require '../util/constraint'
detect = require '../util/detect'
lang = require '../locales/lang'

StoryViewer = React.createFactory require './story-viewer'
MemberCard = React.createFactory require './member-card'
LitePopover = React.createFactory require('react-lite-layered').Popover

LiteModalBeta = React.createFactory require '../module/modal-beta'

{ a, div, span, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'channel-info'
  mixins: [ mixinChannelInfo ]

  propTypes:
    _teamId: T.string.isRequired
    _channelType: T.string.isRequired
    channel: T.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showMemberCard: false
    showStoryViewer: false

  componentDidMount: ->
    @_headerEl = @refs.header

  getBaseArea: ->
    @_headerEl?.getBoundingClientRect() or {}

  positionAlgorithm: (area) ->
    top: area.top + 56
    left: area.left

  togglePopover: ->
    @setState showMemberCard: not @state.showMemberCard

  onTitleClick: (event) ->
    if @props._channelType is 'chat'
      event.stopPropagation()
      @togglePopover()

  onStoryViewerClose: ->
    @setState showStoryViewer: false

  onPreviewClick: ->
    @setState showStoryViewer: true

  onOpenLink: (event) ->
    event.preventDefault()

    href = @props.channel.getIn [ 'data', 'url' ]
    window.open urlParse href, true

  renderPreview: ->
    return noscript() unless @props._channelType is 'story'
    return noscript() unless detect.isImageWithPreview(@props.channel.get('data'))

    url = constraint.thumbnail @props.channel.getIn([ 'data', 'thumbnailUrl' ]), 40, 56

    span
      className: 'preview flex-static'
      style: backgroundImage: "url(#{ url })"
      onClick: @onPreviewClick

  renderTitle: ->
    cxSpan = cx 'title', 'text-overflow', 'flex-static', 'is-clickable': @props._channelType is 'chat'
    span className: cxSpan, onClick: @onTitleClick, @extractTitle()

  renderArchivedInfo: ->
    return null if not @props.channel.get('isArchived')
    cxSpan = cx 'archived', 'flex-static', 'muted'
    span className: cxSpan, "(#{lang.getText('archived-topic')})"

  renderUrl: ->
    return noscript() if @props.channel.get('category') isnt 'link'
    a className: 'url text-overflow', onClick: @onOpenLink, @props.channel.getIn [ 'data', 'url' ]

  renderMemberCard: ->
    LitePopover
      baseArea: if @state.showMemberCard then @getBaseArea() else {}
      onPopoverClose: @togglePopover
      positionAlgorithm: @positionAlgorithm
      showClose: false
      show: @state.showMemberCard
      name: 'member-card'
      MemberCard
        _teamId: @props._teamId
        member: @props.channel
        showEntrance: false

  renderStoryViewer: ->
    LiteModalBeta
      name: 'story-viewer'
      show: @state.showStoryViewer
      onCloseClick: @onStoryViewerClose
      StoryViewer
        story: @props.channel
        onClose: @onStoryViewerClose

  render: ->
    div className: 'channel-info flex-horiz flex-vcenter', ref: 'header',
      @renderPreview()
      @renderTitle()
      @renderArchivedInfo()
      @renderUrl()
      @renderMemberCard()
      @renderStoryViewer()
