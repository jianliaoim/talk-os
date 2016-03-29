
React = require 'react'
cx = require 'classnames'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

recorder = require 'actions-recorder'

query = require '../query'
orders = require '../util/orders'
lang = require '../locales/lang'

tagActions  = require '../actions/tag'
notifyActions  = require '../actions/notify'

mixinSubscribe = require '../mixin/subscribe'
LiteModal = React.createFactory require 'react-lite-layered/lib/modal'
LiteDialog = React.createFactory require 'react-lite-layered/lib/dialog'

div = React.createFactory 'div'
span = React.createFactory 'span'
input = React.createFactory 'input'
button = React.createFactory 'button'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'tag'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    tag: T.instanceOf(Immutable.Map)
    editable: T.bool
    onTagClick: T.func
    tagSelected: T.string
    _teamId: T.string.isRequired

  getDefaultProps: ->
    editable: false
    onTagClick: ->

  getInitialState: ->
    showEditor: false
    showDeleter: false
    contacts: @getContacts()
    user: query.user(recorder.getState())

  componentDidMount: ->
    @subscribe recorder, =>
      @setState contacts: @getContacts()

  hasAuth: (tag) ->
    currentUserId = @state.user.get('_id')
    userContact = @state.contacts.find (contact) ->
      contact.get('_id') is currentUserId
    hasAuth = (userContact?.get('role') in ['owner', 'admin']) or (tag.get('_creatorId') is currentUserId)

  getContacts: ->
    query.contactsBy(recorder.getState(), @props._teamId) or Immutable.List()

  removeTag: ->
    tagActions.removeTag @props.tag.get('_id')

  onRemoveClick: ->
    @setState showDeleter: true

  onConfrimClick: ->
    tags = query.tagsBy(recorder.getState(), @props._teamId)
    tagNames = tags.map (tag) -> tag.get('name')
    @_inputEl = @refs.input
    value = @_inputEl.value
    if value? and not tagNames.contains(value) and value.replace(/\s/g, '').length > 0
      tagActions.updateTag @props.tag.get('_id'), @_inputEl.value
      @setState showEditor: false
    else if value is @props.tag.get('name')
      @setState showEditor: false
    else
      notifyActions.error l('tag-modify-fail-message')

  onEditClick: (event) ->
    event.stopPropagation()
    @setState showEditor: true

  onEditorClose: ->
    @setState showEditor: false

  onDeleteClick: ->
    @setState showDeleter: true

  onDeleterClose: ->
    @setState
      showDeleter: false
      showEditor: false

  onTagClick: ->
    @props.onTagClick @props.tag.get('_id')

  renderEditor: ->
    LiteModal
      name: 'tag-editor'
      title: l('edit-tag')
      onCloseClick: @onEditorClose
      show: @state.showEditor
      div className: 'content',
        span className:'rich-line', l('tag-name')
        input className: 'input', type: 'text', ref: 'input', autoFocus: true, defaultValue: @props.tag.get('name')
        div className: 'button-group',
          button className: 'button is-primary', onClick: @onConfrimClick, l('save-tag-edit')
          button className: 'button is-danger', onClick: @onDeleteClick, l('remove-tag')

  renderDeleter: ->
    LiteDialog
      cancel: l('cancel')
      confirm: l('confirm')
      content: l('tag-deleter-message')
      flexible: true
      show: @state.showDeleter
      onCloseClick: @onDeleterClose
      onConfirm: @removeTag

  render: ->
    tag = @props.tag
    className = cx 'tag', 'text-overflow', 'is-active': (tag.get('_id') is @props.tagSelected)
    if @props.editable
      if @hasAuth tag
        div className: className, onClick: @onTagClick,
          span className: 'dot'
          span className: 'name', tag.get('name')
          span className: 'edit icon icon-pencil', onClick: @onEditClick
          @renderEditor()
          @renderDeleter()
      else
        div className: className, onClick: @onTagClick,
          span className: 'dot'
          span className: 'name', tag.get('name')
    else
      div className: className, onClick: @onTagClick,
        span className: 'dot'
        span className: 'name', tag.get('name')
