React = require 'react'
Immutable = require 'immutable'

SlimModal = React.createFactory require '../app/slim-modal'
TopicProfile = React.createFactory require '../app/topic-profile'
TopicSelector = React.createFactory require '../app/topic-selector'

div = React.createFactory 'div'
a   = React.createFactory 'a'

roomActions = require '../actions/room'

lang = require '../locales/lang'

l = lang.getText

module.exports =

  # methods need to implement

  getInitialState: ->
    showTopicConfigs: false

  onTopicSelect: (_roomId) -> @setState {_roomId}

  onTopicCreate: -> @setState showTopicConfigs: true
  onTopicClose: -> @setState showTopicConfigs: false

  onTopicSave: (data, cb) ->
    # may not give color due to its modify usage
    data._teamId = @props._teamId
    unless data.color then data.color = 'blue'
    roomActions.roomCreate data, (resp) =>
      cb? resp
      @setState showTopicConfigs: false, _roomId: resp._id

  renderTopicCreate: ->
    SlimModal
      name: 'topic-configs'
      title: l('topic-create'),
      onClose: @onTopicClose
      show: @state.showTopicConfigs
      TopicProfile
        _teamId: @props._teamId
        topic: Immutable.fromJS({name: '', purpose: '', color: 'blue'})
        hasPermission: true
        saveConfigs: @onTopicSave

  renderTopicRow: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', l('choose-topic-for-integration')
        div className: 'about muted',
          l('or-comma')
          a className: 'new-topic', onClick: @onTopicCreate, l('create-a-topic')
      div className: 'value',
        TopicSelector chosen: @state._roomId, onItemClick: @onTopicSelect, _teamId: @props._teamId
