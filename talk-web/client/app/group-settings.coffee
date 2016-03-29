React = require 'react'
cx = require 'classnames'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

lang = require '../locales/lang'

search = require '../util/search'
diff   = require '../util/diff'
orders = require '../util/orders'

groupActions = require '../actions/group'
notifyActions = require '../actions/notify'

SearchList = React.createFactory require './search-list'
SlimModal = React.createFactory require './slim-modal'
ButtonSingleAction = React.createFactory require '../module/button-single-action'

{ h, div, span, input, button } = React.DOM

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'group-board'

  mixins: [ LinkedStateMixin, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    group: T.instanceOf(Immutable.Map)
    groups: T.instanceOf(Immutable.List).isRequired
    contacts: T.instanceOf(Immutable.List)
    onClose: T.func.isRequired
    onReturn: T.func

  getDefaultProps: ->
    group: Immutable.Map()

  getInitialState: ->
    value: @props.group.get('name') or ''
    _memberIds: @props.group.get('_memberIds') or Immutable.List()

  nameExists: (name) ->
    @props.groups.some (group) ->
      group.get('name') is name

  createGroup: (completeCB) ->
    if @isFormValid()
      data =
        _teamId: @props._teamId
        name: @state.value
        _memberIds: @state._memberIds

      groupActions.create data
      , =>
        @props.onClose()
        completeCB()
      , ->
        completeCB()
    else
      completeCB()

  getRemoveMembers: ->
    @props.group.get('_memberIds').filterNot (_id) =>
      @state._memberIds.contains _id

  getAddMembers: ->
    @state._memberIds.filterNot (_id) =>
      @props.group.get('_memberIds').contains _id

  isFormValid: ->
    name = @state.value.trim()
    if name.length is 0
      notifyActions.error l('team-group-name-min-length')
      false
    else if name.length > 24
      notifyActions.error l('team-group-name-max-length')
      false
    else if (name isnt @props.group.get('name')) and @nameExists(name)
      notifyActions.error l('team-group-name-exists')
      false
    else
      true

  updateGroup: ->
    if @isFormValid()
      data =
        addMembers: @getAddMembers().toJS()
        removeMembers: @getRemoveMembers().toJS()

      if @props.group.get('name') isnt @state.value then data.name = @state.value

      if data.name or (data.addMembers.length > 0) or (data.removeMembers.length > 0)
        groupActions.update @props.group.get('_id'), data, (resp) =>
          @props.onClose()
      else
        notifyActions.info l('team-group-no-change')

  onReturn: ->
    @props.onReturn()

  onMemberClick: (member) ->
    _memberIds = diff.toggle @state._memberIds, member.get('_id')
    @setState { _memberIds }

  renderFooter: ->
    div className: 'footer',
      if @props.group.isEmpty()
        ButtonSingleAction className: 'button', onClick: @createGroup, l('create-group')
      else
        ButtonSingleAction className: 'button', onClick: @updateGroup, l('save-changes')

  renderSearchList: ->
    contacts = @props.contacts
    .filterNot (contact) ->
      contact.get('isRobot')
    .sort orders.byPinyin

    SearchList
      _teamId: @props._teamId
      contacts: contacts
      selectedContacts: @state._memberIds
      onContactClick:  @onMemberClick
      title: l('filter-members')
      locale:  l('search-members')
      placeholder: l('no-contact-result')

  render: ->
    div className: 'group-settings flex-vert',
      div className: 'section flex-static',
        l('team-group-name')
        input type: 'text', className: 'form-control', placeholder: l('team-group-name-placeholder'), valueLink: @linkState('value'), autoFocus: true
      @renderSearchList()
      @renderFooter()
