React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'
query = require '../query'

format    = require '../util/format'

notifyActions = require '../actions/notify'

div      = React.createFactory 'div'
span     = React.createFactory 'span'
a        = React.createFactory 'a'
label    = React.createFactory 'label'
input    = React.createFactory 'input'
br       = React.createFactory 'br'
textarea = React.createFactory 'textarea'
button   = React.createFactory 'button'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'topic-configs'
  mixins: [PureRenderMixin]

  propTypes:
    topic:          T.instanceOf(Immutable.Map)
    _teamId:        T.string
    hasPermission:  T.bool.isRequired
    saveConfigs:    T.func.isRequired

  getInitialState: ->
    topic: @props.topic.get('topic')
    purpose: @props.topic.get('purpose')
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
    if @state.isPrivate isnt @props.topic.get('isPrivate')  then return true
    return false

  saveConfigs: ->
    unless @state.topic? and 0 < @state.topic.length < 30
      notifyActions.warn lang.getText('invalid-length')
      return
    unless @isNameUnique()
      notifyActions.warn lang.getText('topic-name-existed')
      return
    data = {}
    if @state.topic     isnt @props.topic.get('topic')      then data.topic = @state.topic
    if @state.purpose   isnt @props.topic.get('purpose')    then data.purpose = @state.purpose
    if @state.isPrivate isnt @props.topic.get('isPrivate')  then data.isPrivate = @state.isPrivate
    if Object.keys(data).length > 0
      @setState buttonDisabled: true
      @props.saveConfigs data, (resp) =>
        @setState buttonDisabled: false

  # event handlers

  onTopicChange: (event) ->
    if @props.hasPermission
      topic = format.trimLeft event.target.value
      @setState {topic}

  onPurposeChange: (event) ->
    if @props.hasPermission
      purpose = format.trimLeft event.target.value
      @setState {purpose}

  onPublicClick:  -> if @props.hasPermission then @setState isPrivate: false
  onPrivateClick: -> if @props.hasPermission then @setState isPrivate: true

  # render methods

  renderPrivate: ->
    if not @props.topic.get('isGeneral')
      div className: 'form-group',
        label null, lang.getText('openness')
        div className: 'configs',
          label className: 'line', onClick: @onPublicClick,
            input readOnly: true, type: 'radio', checked: (not @state.isPrivate)
            lang.getText('about-public-topic')
          br()
          label className: 'line', onClick: @onPrivateClick,
            input readOnly: true, type: 'radio', checked: @state.isPrivate
            lang.getText('about-private-topic')

  render: ->
    className =  cx 'form-group', { 'is-disabled': !@props.hasPermission }

    div className: 'topic-configs',
      unless @props.topic.get('isGeneral') then div className: 'form-group',
        label null, lang.getText('topic-name')
        input
          type: 'text', key: 'input', className: 'form-control', value: @state.topic
          placeholder: lang.getText('topic-name-placeholder')
          onChange: @onTopicChange
          readOnly: (not @props.hasPermission)
          autoFocus: true
      div className: 'form-group',
        label null, lang.getText('topic-purpose')
        textarea
          className: 'form-control', value: @state.purpose
          placeholder: lang.getText('topic-purpose-placeholder')
          onChange: @onPurposeChange
          readOnly: (not @props.hasPermission)

      @renderPrivate()

      if @props.hasPermission
        className = cx 'button', 'is-primary', 'is-extended',
          'is-disabled': not @needSave()

        button className: className, onClick: @saveConfigs, disabled: @state.buttonDisabled,
          lang.getText('save')
