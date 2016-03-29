React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
query = require '../query'

format    = require '../util/format'

notifyActions = require '../actions/notify'

ButtonSingleAction = React.createFactory require '../module/button-single-action'

{ a, div, span, input, button, textarea } = React.DOM

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'topic-profile'
  mixins: [PureRenderMixin]

  propTypes:
    topic:          T.instanceOf(Immutable.Map)
    _teamId:        T.string
    hasPermission:  T.bool.isRequired
    saveConfigs:    T.func.isRequired

  getInitialState: ->
    topic: @props.topic.get('topic')
    purpose: @props.topic.get('purpose')
    color: @props.topic.get('color')
    isPrivate: @props.topic.get('isPrivate') or false
    buttonDisabled: false

  # user methods

  getRooms: ->
    query.orList(query.topicsBy(recorder.getState(), @props._teamId or @props.topic.get('_teamId')))

  getArchivedTopics: ->
    query.orList(query.archivedTopicsBy(recorder.getState(), @props._teamId or @props.topic.get('_teamId')))

  isNameUnique: ->
    @getRooms().concat(@getArchivedTopics())
    .filterNot (room) => room.get('_id') is @props.topic.get('_id')
    .every (room) =>
      room.get('topic') isnt @state.topic.trim()

  needSave: ->
    if @state.topic     isnt @props.topic.get('topic')      then return true
    if @state.purpose   isnt @props.topic.get('purpose')    then return true
    if @state.color     isnt @props.topic.get('color')      then return true
    if @state.isPrivate isnt @props.topic.get('isPrivate')  then return true
    return false

  saveConfigs: (completeCB) ->
    unless @state.topic? and 0 < @state.topic.length < 30
      notifyActions.warn lang.getText('invalid-length')
      completeCB()
      return
    unless @isNameUnique()
      notifyActions.warn lang.getText('topic-name-existed')
      completeCB()
      return
    data = {}
    if @state.topic     isnt @props.topic.get('topic')      then data.topic = @state.topic
    if @state.purpose   isnt @props.topic.get('purpose')    then data.purpose = @state.purpose
    if @state.color     isnt @props.topic.get('color')      then data.color = @state.color
    if @state.isPrivate isnt @props.topic.get('isPrivate')  then data.isPrivate = @state.isPrivate
    if Object.keys(data).length > 0
      @setState buttonDisabled: true
      @props.saveConfigs data
      , (resp) =>
        @setState buttonDisabled: false
        completeCB()
      , ->
        completeCB()

  # event handlers

  onTopicChange: (event) ->
    if @props.hasPermission
      topic = format.trimLeft event.target.value
      @setState {topic}

  onPurposeChange: (event) ->
    if @props.hasPermission
      purpose = format.trimLeft event.target.value
      @setState {purpose}

  onColorClick: (color) ->
    if @props.hasPermission
      @setState {color}

  onPublicClick:  -> if @props.hasPermission then @setState isPrivate: false
  onPrivateClick: -> if @props.hasPermission then @setState isPrivate: true

  # render methods

  renderPrivate: ->
    if not @props.topic.get('isGeneral')
      div className: 'section',
        lang.getText('openness')
        div className: 'configs',
          div className: 'line', onClick: @onPublicClick,
            input readOnly: true, type: 'radio', checked: (not @state.isPrivate)
            lang.getText('about-public-topic')
          div className: 'line', onClick: @onPrivateClick,
            input readOnly: true, type: 'radio', checked: @state.isPrivate
            lang.getText('about-private-topic')

  renderFooter: ->
    div className: 'footer',
      ButtonSingleAction className: 'button', onClick: @saveConfigs, lang.getText('create')

  render: ->
    div className: 'topic-profile',
      unless @props.topic.get('isGeneral')
        div className: 'section',
          lang.getText('topic-name')
          input
            type: 'text', key: 'input', className: 'form-control', value: @state.topic
            placeholder: lang.getText('topic-name-placeholder')
            onChange: @onTopicChange
            readOnly: (not @props.hasPermission)
            autoFocus: true
      div className: 'section',
        lang.getText('topic-purpose')
        textarea
          className: 'form-control is-static', value: @state.purpose
          placeholder: lang.getText('topic-purpose-placeholder')
          onChange: @onPurposeChange
          readOnly: (not @props.hasPermission)
      @renderPrivate()
      @renderFooter()
