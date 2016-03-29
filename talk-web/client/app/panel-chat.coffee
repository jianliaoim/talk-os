React = require 'react'
Immutable = require 'immutable'
cx = require 'classnames'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
mixinQuery = require '../mixin/query'

detect = require '../util/detect'
search = require '../util/search'
orders = require '../util/orders'
analytics = require '../util/analytics'

lang = require '../locales/lang'

contactActions = require '../actions/contact'

Permission = require '../module/permission'

routerHandlers = require '../handlers/router'

ContactName = React.createFactory require './contact-name'
SearchBox = React.createFactory require('react-lite-misc').SearchBox

{ a, p, div, span, input, textarea } = React.DOM

T = React.PropTypes


module.exports = React.createClass
  displayName: 'panel-chat'

  mixins: [PureRenderMixin, mixinQuery]

  propTypes:
    _teamId: T.string.isRequired
    contacts: T.instanceOf(Immutable.List).isRequired
    leftContacts: T.instanceOf(Immutable.List).isRequired
    onClose: T.func

  getInitialState: ->
    showForm: false
    value: ''

  filterList: (list) ->
    search.forMembers list, @state.value, getAlias: @getContactAlias
    .sort orders.byPinyin

  onAddClick: ->
    @setState showForm: (not @state.showForm)

  onChange: (value) ->
    @setState { value }

  onItemClick: (contact) ->
    _userId = query.userId(recorder.getState())
    if contact.get('_id') isnt _userId
      routerHandlers.chat @props._teamId, contact.get('_id'), {}, @props.onClose
      analytics.enterChatFromStory()

  renderContacts: (type) ->
    if type is 'leftContacts'
      filteredList = @filterList(@props.leftContacts)
      info = lang.getText('contact-quitted')
    else
      filteredList = @filterList(@props.contacts)
      info = lang.getText('members-list')

    if filteredList.size > 0
      div className: 'item-list contact-list',
        p className: 'info muted', "#{info} (#{filteredList.size})"
        if filteredList.size > 0
          filteredList.map (contact) =>
            onItemClick = =>
              @onItemClick contact

            ContactName
              key: contact.get('_id')
              contact: contact
              _teamId: @props._teamId
              onClick: onItemClick

  renderHeader: ->
    div className: 'header',
      SearchBox
        value: @state.value
        onChange:  @onChange
        locale: lang.getText('search-members')
        autoFocus: not detect.isIPad()

  render: ->
    div className: 'panel-chat',
      @renderHeader()
      @renderContacts()
      @renderContacts('leftContacts')
