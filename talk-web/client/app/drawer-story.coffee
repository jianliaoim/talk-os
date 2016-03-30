React = require 'react'
assign = require 'object-assign'
isEqual = require 'lodash.isequal'
isMatch = require 'lodash.ismatch'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'

storyActions = require '../actions/story'
settingsActions = require '../actions/settings'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'

Permission = require '../module/permission'

FormFile = React.createFactory require './form-file'
FormLink = React.createFactory require './form-link'
FormTopic = React.createFactory require './form-topic'
StoryViewer = React.createFactory require './story-viewer'

Icon = React.createFactory require '../module/icon'
CreatorInfo = React.createFactory require '../module/creator-info'
LightModalBeta = React.createFactory require '../module/light-modal'

{ a, div, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'drawer-story'
  mixins: [ mixinQuery, mixinSubscribe, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string
    story: T.instanceOf(Immutable.Map)

  getInitialState: ->
    contacts: @getContacts()
    readOnly: true
    canSubmit: true
    willSubmit: false
    showStoryViewer: false

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        contacts: @getContacts()

  handleFormDataSubmit: (data) ->

    setState = =>
      @setState
        readOnly: true
        willSubmit: false

    isntDataChange = isMatch @props.story.get('data').toJS(), data.toJS()

    if isntDataChange
      setState()
      return

    data =
      data: data.toJS()
      category: @props.story.get 'category'

    storyActions.update @props.story.get('_id'), data
    , (resp) ->
      setState()
    , (error) ->
      console.error error

  onCancelEdit: (event) ->
    event.stopPropagation()
    @setState
      readOnly: true
      canSubmit: true

  onCloseDrawer: ->
    settingsActions.closeDrawer()

  onDeleteImage: ->
    @setState canSubmit: false

  onStartEdit: (event) ->
    event.stopPropagation()
    @setState
      readOnly: false

  onSubmitEdit: (event) ->
    event.stopPropagation()
    @setState
      willSubmit: true

  onUploadedImage: ->
    @setState canSubmit: true

  onImageClick: ->
    @setState showStoryViewer: true

  onStoryViewerClose: ->
    @setState showStoryViewer: false

  renderStoryViewer: ->
    LightModalBeta
      name: 'story-viewer'
      show: @state.showStoryViewer
      onCloseClick: @onStoryViewerClose
      StoryViewer
        story: @props.story
        onClose: @onStoryViewerClose

  render: ->

    formProps = =>
      data: @props.story.get 'data'
      onSubmit: @handleFormDataSubmit
      readOnly: @state.readOnly
      willSubmit: @state.willSubmit
      displayMode: 'edit'

    div className: 'drawer-story flex-vert',
      if @state.readOnly
        div className: 'header flex-horiz flex-between flex-vcenter',
          CreatorInfo
            name: @props.story.getIn [ 'creator', 'name' ]
            avatarUrl: @props.story.getIn [ 'creator', 'avatarUrl' ]
            className: 'flex-space'
            createTime: @props.story.get 'createdAt'
            updateTime: @props.story.get 'updatedAt'
          div className: 'action row large flex-horiz flex-vcenter',
            EditClassPermission
              _teamId: @props._teamId
              _creatorId: @props.story.get '_creatorId'
              onClick: @onStartEdit
            a className: 'btn btn-close', onClick: @onCloseDrawer,
              Icon name: 'remove', size: 20
      else
        div className: 'header flex-horiz flex-between',
          a className: 'btn btn-return', onClick: @onCancelEdit, Icon name: 'arrow-left', size: 20
          if @state.canSubmit
            a className: 'btn btn-done', onClick: @onSubmitEdit, Icon name: 'tick', size: 20
          else noscript()
      div className: 'body flex-space thin-scroll',
        switch @props.story.get 'category'
          when 'file' then FormFile assign formProps(), { onDelete: @onDeleteImage, onUploaded: @onUploadedImage, imageWidth: 459, onImageClick: @onImageClick }
          when 'link' then FormLink formProps()
          when 'topic' then FormTopic formProps()
          else noscript()
      @renderStoryViewer()

EditClass = React.createClass

  propTypes:
    onClick: T.func.isRequired

  render: ->
    a className: 'btn btn-edit', onClick: @props.onClick,
      Icon name: 'edit', size: 18

EditClassPermission = React.createFactory Permission.create EditClass, Permission.admin
