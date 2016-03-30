cx     = require 'classnames'
React  = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
search = require '../util/search'
tagActions     = require '../actions/tag'
messageActions = require '../actions/message'

mixinSubscribe = require '../mixin/subscribe'

lang     = require '../locales/lang'

Tag =  React.createFactory require '../app/tag'

SearchBox        = React.createFactory require('react-lite-misc').SearchBox
ReactCSSTransitionGroup = React.createFactory require 'react-addons-css-transition-group'

div  = React.createFactory 'div'
input  = React.createFactory 'input'
span = React.createFactory 'span'

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'tag-shelf'
  mixins: [ mixinSubscribe, PureRenderMixin ]

  propTypes:
    tags:       T.instanceOf(Immutable.List)
    _tagId:     T.string
    _userId:    T.string
    selecteAll: T.bool
    onTagClick: T.func.isRequired
    onAllTagsSelect: T.func.isRequired

  getInitialState: ->
    query: ''
    contacts: @getContacts()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        contact: @getContacts()

  getContacts: ->
    query.contactsBy(recorder.getState(), @props._teamId)

  getTagName: ->
    tag = @props.tags.find (tag) =>
      tag.get('_id') is @props._tagId
    tag?.get('name')

  onEditFinish: ->
    @setState editable: false

  onEditClick: ->
    @setState editable: true

  onQueryChange: (query) ->
    @setState query: query

  onCreateTag: ->
    tagActions.createTag @props._teamId, @state.query.trim()

  filteredTags: ->
    search.forTags @props.tags, @state.query.trim()

  nameExsits: ->
    @filteredTags().some (tag) =>
      tag.get('name') is @state.query.trim()

  tagExsits: ->
    @filteredTags().some (tag) =>
      tag.get('_id') is @props._tagId

  renderTagList: ->
    @filteredTags().map (tag) =>
      _tagId = tag.get('_id')
      cxItem = cx 'tag', 'item', 'muted', 'is-selected': @props._tagId is _tagId

      Tag
        key: _tagId
        tag: tag
        editable: true
        onTagClick: @props.onTagClick
        tagSelected: @props._tagId
        _teamId: @props._teamId

  renderSearchbox: ->
    SearchBox
      value: @state.query
      onChange: @onQueryChange
      locale: l('filter-tag-name')
      autoFocus: false

  renderPlaceholder: ->
    span className: 'muted placeholder', l('no-tag')

  render: ->
    _creatorIds = @props.tags.map((tag) -> tag.get('_creatorId'))

    # @props._tagId对应标签不存在时默认选中“全部标签”
    cxAll = cx 'tag', 'line', 'muted', 'is-active': @props.selectAll or not @tagExsits()

    div className: 'tag-shelf',
      div className: 'title',
        @renderSearchbox()
      if @state.query.trim().length isnt 0 and not @nameExsits()
        div className: 'create-btn muted line flex-horiz', onClick: @onCreateTag,
          span className: 'ti ti-plus-circle-solid'
          "#{l('add-tag')} \"#{@state.query.trim()}\""
      div className: 'current', onClick: @props.onAllTagsSelect,
        ReactCSSTransitionGroup
          transitionName: 'fade'
          className: 'fade'
          transitionEnterTimeout: 200
          transitionLeaveTimeout: 200
          # @props._tadId不存在或对应的标签被删除时不显示
          if @tagExsits()
            span className: 'tag line',
              span className: 'dot'
              span className: 'name', @getTagName()
      div className: 'tags shelf thin-scroll',
        if @props.tags.size > 0
          div className: 'tag-list',
            div className: cxAll, onClick: @props.onAllTagsSelect,
              span className: 'dot'
              span className: 'name', lang.getText('all-tags')
            @renderTagList()
        else
          @renderPlaceholder()
