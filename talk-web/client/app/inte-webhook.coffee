React = require 'react'
Immutable = require 'immutable'
classnames = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

lang = require '../locales/lang'

mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'

inteActions = require '../actions/inte'

fieldsReader = require '../util/fields-reader'

CopyArea = React.createFactory require('react-lite-misc').Copyarea

div   = React.createFactory 'div'
span  = React.createFactory 'span'
a     = React.createFactory 'a'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'inte-webhook'
  mixins: [
    LinkedStateMixin
    mixinCreateTopic, mixinInteHandler
    PureRenderMixin
  ]

  propTypes:
    _teamId:  T.string.isRequired
    _roomId:  T.string.isRequired
    onPageBack:  T.func.isRequired
    inte:     T.object
    settings: T.object.isRequired # immutable object

  getInitialState: ->
    # see mixins for more state
    webhookUrl: @props.inte?.get('webhookUrl') or null
    token: @props.inte?.get('token') or undefined

  # methods

  needToken: ->
    @props.settings.get('fields')
    .some (field) ->
      field.get('key') is 'token'

  isToSubmit: ->
    unless @state._roomId then return false
    return true

  hasChanges: ->
    unless @props.inte?
      return false

    @props.settings.get('fields')
    .filter (field) -> not field.get('readonly')
    .some (field) =>
      @state[field.get('key')] isnt @props.inte.get(field.get('key'))

  # events

  # ajax events

  onCreate: ->
    unless @isToSubmit() then return false
    return false if @state.isSending

    data =
      _teamId: @props._teamId
      _roomId: @state._roomId
      category: @props.settings.get('name')

    @setState isSending: true
    inteActions.inteCreate data,
      (resp) =>
        @setState webhookUrl: resp.webhookUrl, isSending: false
        @props.onInteEdit Immutable.fromJS(resp)
      (error) =>
        @setState isSending: false

  onUpdate: ->
    return false unless @hasChanges()
    return false if @state.isSending

    data = {}
    @props.settings.get('fields')
    .filter (field) -> not field.readonly
    .map (field) =>
      if @state[field.get('key')] isnt @props.inte.get(field.get('key'))
        data[field.get('key')] = @state[field.get('key')]

    @setState isSending: true
    inteActions.inteUpdate @props.inte.get('_id'), data,
      (resp) =>
        @setState isSending: false
        @onPageBack true
      (error) =>
        @setState isSending: false

  # renderers

  renderInteWebhookUrl: ->
    settings = @props.settings.toJS()
    field = fieldsReader.getField settings.fields, 'webhookUrl'
    language = lang.getLang()

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', l('generate-webhook')
        div className: 'about muted', field.description[language]
      div className: 'value',
        CopyArea text: @state.webhookUrl

  render: ->

    div className: 'inte-webhook inte-board lm-content',
      @renderInteHeader()
      @renderTopicRow()
      if @props.inte?
        @renderInteGuide()
      if @props.inte?
        @renderInteWebhookUrl()
      else
        @renderInteCreate()
      if @props.inte?
        div null,
          if @needToken()
            @renderInteToken()
          @renderInteTitle()
          @renderInteDesc()
          @renderInteIcon()
          @renderInteModify()

      # modals
      @renderTopicCreate()
