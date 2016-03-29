React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

lang = require '../locales/lang'

search = require '../util/search'
mixinUser = require '../mixin/user'
mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'

refine = require '../util/refine'
reorder = require '../util/reorder'

SearchList = React.createFactory require './search-list'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ div, span, button } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'roster-management'
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
    isRemovable: false
    selectedContacts: Immutable.List()

  getInitialState: ->
    groups: @getInitialGroups()
    contacts: @getInitialContacts()
    selectedGroups: Immutable.List()
    selectedContacts: @props.selectedContacts

  componentDidMount: ->
    @staticSelects = @props.selectedContacts

    @subscribe recorder, =>
      contacts = @getInitialContacts()
      groups =@getInitialGroups()

      @setState
        groups: groups
        contacts: contacts

  getInitialContacts: ->
    @getContacts()
    .filterNot refine.byId @getUserId()
    .sortBy reorder.byPinyin
    .sortBy reorder.byRobot
    .sortBy (contact) =>
      not @props.selectedContacts.includes contact.get '_id'

  getInitialGroups: ->
    @getGroups()
    .sortBy reorder.byName
    .unshift @createGroupAll(@getContacts())

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
    isStatic = not @props.isRemovable and @staticSelects.includes targetId

    if selectedContacts.includes targetId
      if not isStatic
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
      selectedContacts = selectedContacts.filterNot (id) =>
        isStatic = not @props.isRemovable and @staticSelects.includes id
        isMe = @getUserId() is id
        return false if isStatic or isMe
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

  renderFooter: ->
    div className: 'footer',
      span className: 'button', onClick: @handleSubmit, lang.getText('confirm')

  renderSearchList: ->
    SearchList
      _teamId: @props._teamId
      contacts: @state.contacts
      groups: @state.groups
      selectedContacts: @state.selectedContacts
      selectedGroups: @state.selectedGroups
      onContactClick: @handleSelectContact
      onGroupClick: @handleSelectGroup
      locale: lang.getText('search-members')
      placeholder: lang.getText('no-contact-result')

  render: ->
    div className: 'roster-management flex-vert',
      @renderSearchList()
      @renderFooter()
