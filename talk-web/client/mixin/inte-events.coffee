React = require 'react'
Immutable = require 'immutable'

lang = require '../locales/lang'

LightCheckbox = React.createFactory require '../module/light-checkbox'

div = React.createFactory 'div'

l = lang.getText

module.exports =

  getInitialState: ->
    inte = @props.inte

    # returns obejct
    events: inte?.get('events') or Immutable.List()

  # methods

  getEventsField: ->
    fields = @props.settings.get('fields')
    fields.find (field) ->
      field.get('key') is 'events'

  isGroupAllSelected: (eventGroup) ->
    eventsField = @getEventsField()
    eventNames = @state.events.toJS()

    eventsField.get('items')
    .filter (event) ->
      event.get('group') is eventGroup
    .every (event) ->
      event.get('key') in eventNames

  # events

  onEventToggle: (eventKey) ->
    eventNames = @state.events.toJS()
    if eventKey in eventNames
      newEvents = @state.events.filter (existingEventKey) ->
        existingEventKey isnt eventKey
    else
      newEvents = @state.events.concat Immutable.List([eventKey])
    @setState events: newEvents.sort()

  onEventGroupToggle: (eventGroup) ->
    eventsField = @getEventsField()
    newStatus = not @isGroupAllSelected(eventGroup)
    newEvents = @state.events
    newEventNames = newEvents.toJS()
    eventsField.get('items')
    .filter (event) ->
      event.get('group') is eventGroup
    .forEach (event) ->
      if newStatus
        unless event.get('key') in newEventNames
          newEvents = newEvents.push event.get('key')
      else
        newEvents = newEvents.filter (eventKey) ->
          eventKey isnt event.get('key')
      return true
    @setState events: newEvents.sort()

  # renderers

  renderCheckbox: (field) ->

    language = lang.getLang()
    eventNames = @state.events.toJS()

    LightCheckbox
      key: field.get('key')
      checked: field.get('key') in eventNames
      event: field.get('key')
      name: field.get('label').get(language)
      onClick: @onEventToggle

  renderEventsGroup: ->

    eventsField = @getEventsField()
    eventGroups = eventsField.get('groups')
    language = lang.getLang()

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('integration-notifications')
      div className: 'value',
        eventGroups.map (eventGroup) =>
          eventsInGroup = eventsField.get('items').filter (event) ->
            event.get('group') is eventGroup.get('key')
          div className: 'event-group', key: eventGroup.get('key'),
            LightCheckbox
              checked: @isGroupAllSelected eventGroup.get('key')
              event: eventGroup.get('key')
              name: eventGroup.get('label').get(language)
              onClick: @onEventGroupToggle
            div className: 'event-children',
              eventsInGroup.map @renderCheckbox

  renderEventsList: ->
    fields = @props.settings.get('fields')
    eventFields = fields.find (field) ->
      field.get('key') is 'events'

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', l('integration-notifications')
      div className: 'value',
        eventFields.get('items').map @renderCheckbox

  renderEvents: ->
    eventsField = @getEventsField()
    if eventsField.has('groups')
      @renderEventsGroup()
    else
      @renderEventsList()
