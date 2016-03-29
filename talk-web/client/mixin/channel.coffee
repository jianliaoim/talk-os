recorder = require 'actions-recorder'

mixinSubscribe = require './subscribe'

query = require '../query'
eventBus = require '../event-bus'

module.exports =
  mixins: [mixinSubscribe]

  getInitialState: ->
    isTuned: @getTuned()
    isClearingUnread: @getIsClearingUnread()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        isTuned: @getTuned()
        isClearingUnread: @getIsClearingUnread()

    if @state.isSearch
      @highlightSelectedMessage()
    else
      eventBus.emit 'dirty-action/new-message'

  getIsClearingUnread: ->
    query.isClearingUnread recorder.getState(), @props._teamId, @props._channelId

  getTuned: ->
    query.isTuned recorder.getState()
