React = require 'react'
Immutable = require 'immutable'

LiteModal = React.createFactory require 'react-lite-layered/lib/modal'

TopicSelector = React.createFactory require '../app/topic-selector'
TopicConfigs  = React.createFactory require '../app/topic-configs'

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
    LiteModal
      name: 'topic-configs'
      onCloseClick: @onTopicClose
      title: l('topic-create'),
      show: @state.showTopicConfigs
      TopicConfigs
        _teamId: @props._teamId
        topic: Immutable.fromJS({name: '', purpose: '', color: 'blue'})
        hasPermission: true
        saveConfigs: @onTopicSave
        onCloseClick: @onTopicClose

  renderTopicRow: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', l('choose-topic-for-integration')
        div className: 'about muted',
          l('or-comma')
          a className: 'new-topic', onClick: @onTopicCreate, l('create-a-topic')
      div className: 'value',
        TopicSelector chosen: @state._roomId, onItemClick: @onTopicSelect, _teamId: @props._teamId
