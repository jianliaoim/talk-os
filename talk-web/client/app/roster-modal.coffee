React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

lang = require '../locales/lang'

mixinUser = require '../mixin/user'
mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'

refine = require '../util/refine'
reorder = require '../util/reorder'

RosterList = React.createFactory require './roster-list'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, button } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'roster-modal'
  mixins: [ mixinQuery, mixinSubscribe, mixinUser, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    onClose: T.func
    onSubmit: T.func
    isRemovable: T.bool
    selectedContacts: T.instanceOf Immutable.List

  getDefaultProps: ->
    onClose: (->)
    onSubmit: (->)
    isRemovable: true
    selectedContacts: Immutable.List()

  getInitialState: ->
    contacts = @filterContacts @getContacts()
    groups = @filterGroups @getGroups(), contacts

    groups: groups
    contacts: contacts
    selectedGroups: Immutable.List()
    selectedContacts: @props.selectedContacts

  componentDidMount: ->
    @subscribe recorder, =>
      contacts = @filterContacts @getContacts()
      groups = @filterGroups @getGroups(), contacts

      @setState
        groups: groups
        contacts: contacts

  filterContacts: (contacts) ->
    contacts
    .filterNot refine.byId @getUserId()
    .sortBy reorder.byPinyin
    .sortBy reorder.byRobot
    .sortBy (contact) =>
      not @props.selectedContacts.includes contact.get '_id'

  filterGroups: (groups, contacts) ->
    groups
    .sortBy reorder.byName
    .unshift @createGroupAll contacts

  createGroupAll: (contacts) ->
    _memberIds = contacts
    .filterNot refine.isRobot
    .map (contact) ->
      contact.get '_id'

    Immutable.fromJS
      _id: 'all'
      _memberIds: _memberIds
      name: lang.getText 'everybody'

  handleSelectContact: (contact) ->
    targetId = contact.get '_id'
    selectedContacts = @state.selectedContacts

    if selectedContacts.includes targetId
      selectedContacts = selectedContacts.filterNot (id) ->
        id is targetId
    else
      selectedContacts = selectedContacts.push targetId

    @setState
      selectedContacts: selectedContacts

  handleSelectGroup: (targetGroup) ->
    targetId = targetGroup.get '_id'
    selectedGroups = @state.selectedGroups
    selectedContacts = @state.selectedContacts

    if selectedGroups.includes targetId
      selectedGroups = selectedGroups.filterNot (id) ->
        id is targetId
      selectedContacts = selectedContacts.filterNot (id) ->
        targetGroup.get('_memberIds').includes id
    else
      selectedGroups = selectedGroups.push targetId

    selectedContacts = @state.groups
    .filter (group) -> selectedGroups.includes group.get '_id'
    .flatMap (group) -> group.get '_memberIds'
    .concat selectedContacts
    .toSet()
    .toList()

    @setState
      selectedGroups: selectedGroups
      selectedContacts: selectedContacts

  handleSubmit: ->
    @props.onSubmit @state.selectedContacts
    @props.onClose()

  render: ->
    div className: 'roster-modal',
      div className: 'column-2',
        @renderGroups()
        @renderContacts()
      @renderSubmit()

  renderContacts: ->
    if not @props.isRemovable
      staticSelects = @props.selectedContacts

    RosterList
      _teamId: @props._teamId
      type: 'contact'
      rosters: @state.contacts
      selects: @state.selectedContacts
      onSelect: @handleSelectContact
      className: 'contact'
      staticSelects: staticSelects or Immutable.List()

  renderGroups: ->
    RosterList
      _teamId: @props._teamId
      type: 'group'
      title: lang.getText 'team-groups'
      rosters: @state.groups
      selects: @state.selectedGroups
      onSelect: @handleSelectGroup
      className: 'group'
      showSearch: false

  renderSubmit: ->
    div className: 'action',
      button
        onClick: @handleSubmit
        className: 'button'
        lang.getText 'confirm'
