React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'

query = require '../query'

storyActions = require '../actions/story'

lang = require '../locales/lang'

mixinModal = require '../mixin/modal'

TopicDetails = React.createFactory require './topic-details'

Icon = React.createFactory require '../module/icon'

LiteModalBeta = React.createFactory require '../module/modal-beta'

{ a, div, noscript } = React.DOM
T = React.PropTypes

MODAL_TYPE = [ 'topic-configs' ]

module.exports = React.createClass
  displayName: 'channel-more'
  mixins: [ mixinModal ]

  propTypes:
    _channelId: T.string.isRequired
    _channelType: T.string.isRequired
    onClose: T.func.isRequired
    onInteClick: T.func.isRequired
    channel: T.instanceOf(Immutable.Map).isRequired

  getUserId: ->
    query.userId recorder.getState()

  onDeleteStory: ->
    storyActions.remove @props._teamId, @props._channelId

  onLeaveStory: ->
    storyActions.leave @props._teamId, @props._channelId

  onOpenIntePage: ->
    @props.onClose()
    @props.onInteClick()

  onOpenTopicConfig: ->
    @onOpenModal MODAL_TYPE[0]

  renderModal: ->
    LiteModalBeta
      name: 'channel-more'
      show: @state.showModal
      title: lang.getText @state.modalType
      onCloseClick: @onCloseModal
      switch @state.modalType
        when MODAL_TYPE[0]
          TopicDetails
            topic: @props.channel
            closeView: @onCloseModal
            initialTab: 'topic-configs'
        else noscript()

  renderRoomItems: ->
    div className: 'channel-more',
      a
        className: 'action flex-horiz flex-vcenter'
        onClick: @onOpenTopicConfig
        Icon name: 'pencil'
        lang.getText 'topic-details'
      a
        className: 'action flex-horiz flex-vcenter'
        onClick: @onOpenIntePage
        Icon name: 'config', type: 'icon'
        lang.getText 'integrations'
      @renderModal()

  renderStoryItems: ->
    div className: 'channel-more',
      if @getUserId() isnt @props.channel.get '_creatorId'
        a
          className: 'action flex-horiz flex-vcenter'
          onClick: @onLeaveStory
          Icon name: 'leave', type: 'icon'
          lang.getText 'leave-story'
      else
        null
      a
        className: 'action flex-horiz flex-vcenter'
        onClick: @onDeleteStory
        Icon name: 'trash'
        lang.getText 'trash-story'

  render: ->
    switch @props._channelType
      when 'room'
        @renderRoomItems()
      when 'story'
        @renderStoryItems()
