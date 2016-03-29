React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

inteActions = require '../actions/inte'

mixinInteFactory = require '../mixin/inte-factory'
mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'
mixinInteEvents = require '../mixin/inte-events'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'inte-form'
  mixins: [
    LinkedStateMixin
    mixinInteFactory
    mixinCreateTopic, mixinInteHandler, mixinInteEvents
    PureRenderMixin
  ]

  propTypes:
    _teamId: T.string.isRequired
    _roomId: T.string.isRequired
    onPageBack: T.func.isRequired
    inte: T.object
    settings: T.object.isRequired # immutable object

  getInitialState: ->
    data = @makeInitialState()

    # crazy behavior, due to hard design of inte
    delete data._roomId
    delete data.title
    delete data.description
    delete data.iconUrl

    return data

  onCreate: ->
    return false if @state.isSending
    unless @isToSubmit() then return false

    data = @makeInteData()

    @setState isSending: true
    inteActions.inteCreate data,
      (resp) =>
        @setState isSending: false
        # why is this line?
        @props.onInteEdit Immutable.fromJS(resp)
        @onPageBack true
      (error) =>
        @setState isSending: false

  onUpdate: ->
    return false if @state.isSending
    return false unless @hasChanges()

    data = @pickInteUpdates()

    @setState isSending: true
    inteActions.inteUpdate @props.inte.get('_id'), data,
      (resp) =>
        @setState isSending: false
        @onPageBack()
      (error) =>
        @setState isSending: false

  render: ->
    @renderInteBoard()
