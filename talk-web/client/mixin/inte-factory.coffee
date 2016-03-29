React = require 'react'

fieldsReader = require '../util/fields-reader'

InteValidator = require '../util/inte-validator'

div = React.createFactory 'div'

module.exports =

  makeInitialState: ->
    fields = @props.settings.get('fields').toJS()
    inte = @props.inte
    settings = @props.settings.toJS()

    data = {}
    fields.forEach (field) ->
      key = field.key
      method = InteValidator.mapFieldToDefaultMethod key
      data[key] = method inte, settings
    return data

  isToSubmit: ->
    fields = @props.settings.get('fields').toJS()

    fields
    .filter (field) -> field.required
    .every (field) =>
      key = field.key
      method = InteValidator.mapFieldToDefinedMethod key
      return (method @state[key])

  hasChanges: ->
    return false unless @props.inte?
    fields = @props.settings.get('fields').toJS()

    fields
    .filter (field) -> not field.readonly
    .some (field) =>
      key = field.key
      method = InteValidator.mapFieldToUpdatedMethod key
      return (method @state[key], @props.inte.get(key))

  pickInteUpdates: ->
    fields = @props.settings.get('fields').toJS()
    data = {}

    fields.forEach (field) =>
      key = field.key
      method = InteValidator.mapFieldToUpdatedMethod key
      if (method @state[key], @props.inte.get(key))
        data[key] = @state[key]

    return data

  makeInteData: (isRobot) ->
    fields = @props.settings.get('fields').toJS()
    isRobot = @props.settings.get('name') is 'robot'

    data =
      _teamId: @props._teamId
      category: @props.settings.get('name')

    unless isRobot
      data._roomId = @state._roomId

    fields.forEach (field) =>
      data[field.key] = @state[field.key]

    return data

  renderInteBoard: ->
    settings = @props.settings.toJS()
    fields = settings.fields

    div className: "inte-#{settings.caterory} inte-board lm-content",
      @renderInteHeader()
      if settings.manual?
        @renderInteGuide()
      if fieldsReader.hasField(fields, '_roomId')
        @renderTopicRow()
      if fieldsReader.hasField(fields, 'events')
        @renderEvents()
      if fieldsReader.hasField(fields, 'webhookUrl') and @props.inte?
        @renderWebhookUrl(@props.inte.get('webhookUrl'))
      if fieldsReader.hasField(fields, 'url')
        @renderInteUrl()
      if fieldsReader.hasField(fields, 'token')
        @renderInteToken()
      @renderInteTitle()
      @renderInteDesc()
      @renderInteIcon()
      if @props.inte?
        @renderInteModify()
      else
        @renderInteCreate()
      # modals
      @renderTopicCreate()
