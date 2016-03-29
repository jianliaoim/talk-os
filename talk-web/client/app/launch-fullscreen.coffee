cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'
recorder = require 'actions-recorder'

query = require '../query'
handlers = require '../handlers'

lang = require '../locales/lang'
analytics = require '../util/analytics'

draftActions = require '../actions/draft'
storyActions = require '../actions/story'

mixinQuery = require '../mixin/query'
mixinSubscribe = require '../mixin/subscribe'

LaunchTabpage = React.createFactory require './launch-tabpage'
Icon = React.createFactory require '../module/icon'
ButtonSingleAction = React.createFactory require '../module/button-single-action'

TourGuide = require '../tour-guide'

{ a, li, ul, div, span, button, noscript } = React.DOM
T = React.PropTypes

DEFAULT_TYPE = 'room'
STORY_TYPES = [ 'file', 'link', 'topic' ]

module.exports = React.createClass
  displayName: 'launch-fullscreen'

  mixins: [ mixinQuery, mixinSubscribe ]

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired

  getInitialState: ->
    data: Immutable.Map()
    tabKey: DEFAULT_TYPE
    buttons: [
      { key: 'room', color: 'blue', icon: 'shape', text: 'topic' }
      { key: 'chat', color: 'red', icon: 'private-chat', text: 'chat' }
      { key: 'file', color: 'purple', icon: 'paperclip', text: 'file' }
      { key: 'topic', color: 'yellow', icon: 'idea', text: 'idea' }
      { key: 'link', color: 'green', icon: 'chain', text: 'link' }
    ]

    # store datas
    rooms: @getRooms()
    contacts: @getContacts()
    invitations: @getInvitations()
    leftContacts: @getLeftContacts()
    archivedRooms: @getArchivedRooms()

  componentDidMount: ->
    # 保留 Story -> Topic 的草稿
    for name in ['file', 'link']
      draftActions.deleteStoryDraft @props._teamId, name

    @subscribe recorder, =>
      @setState
        data: @getStoryDraftData @state.tabKey

        # store datas
        rooms: @getRooms()
        contacts: @getContacts()
        invitations: @getInvitations()
        leftContacts: @getLeftContacts()
        archivedRooms: @getArchivedRooms()

    window.addEventListener 'keyup', @onWindowClose

  componentWillUnmount: ->
    window.removeEventListener 'keyup', @onWindowClose

  isStory: (category) ->
    (category or @state.tabKey) in STORY_TYPES

  isValidStoryData: ->
    @state.data?.getIn([ 'data', 'fileKey' ])?.length or @state.data?.getIn([ 'data', 'title' ])?.trim().length

  getStoryDraftData: (category) ->
    if @isStory category
      query.storyDraftBy recorder.getState(), @props._teamId, category

  onCreateStory: (completeCB) ->
    if not @isValidStoryData()
      completeCB()
      return

    switch @state.tabKey
      when 'topic' then analytics.createIdeaStory()
      when 'file' then analytics.createFileStory()
      when 'link' then analytics.createLinkStory()

    data = @getStoryDraftData @state.tabKey
    .set '_teamId', @props._teamId
    .set 'category', @state.tabKey
    .toJS()

    storyActions.create data
    , =>
      @onClearStory()
      completeCB()
    , ->
      completeCB()

  onClearStory: ->
    if @isStory()
      draftActions.deleteStoryDraft @props._teamId, @state.tabKey

  onClose: ->
    handlers.router.back()

  onSwitchTab: (tabKey) ->
    switch tabKey
      when 'room' then analytics.clickRoom()
      when 'chat' then analytics.clickChatFromStory()
      when 'topic' then analytics.clickIdeaStory()
      when 'link' then analytics.clickLinkStory()
      when 'file' then analytics.clickFileStory()
    @setState
      data: @getStoryDraftData tabKey
      tabKey: tabKey

  onWindowClose: (event) ->
    if event.which is 27 then @onClose()

  renderButton: ->
    ul className: 'btns flex-center flex-horiz',
      @state.buttons.map (item, index) =>
        onClick = => @onSwitchTab item.key
        className = cx item.color, 'active': @state.tabKey is item.key

        li key: index, className: (cx 'btn-cell', className),
          button className: (cx 'clr-btn round large', 'trans-surface', className), onClick: onClick,
            Icon size: 24, name: item.icon
          div className: 'text', lang.getText("type-#{item.text}")

  renderClose: ->
    a className: 'btn-close', onClick: @onClose,
      Icon size: 22, name: 'remove'
      'ESC'

  renderStoryAction: ->
    isValidStoryData = @isValidStoryData()
    submitButtonClass = cx 'submit',
      'is-disabled': not isValidStoryData
    cleanButtonClass = cx 'clean',
      'is-disabled': not isValidStoryData

    div className: 'wrapper flex-end flex-horiz flex-vcenter row large',
      button className: cleanButtonClass, onClick: @onClearStory,
        lang.getText('reset-form')
      ButtonSingleAction className: submitButtonClass, onClick: @onCreateStory,
        Icon size: 20, name: 'tick'
        lang.getText('create-story')

  renderTab: ->
    LaunchTabpage
      _teamId: @props._teamId
      _userId: @props._userId
      data: @state.data
      onClose: @props.onClose
      rooms: @state.rooms
      tabKey: @state.tabKey
      contacts: @state.contacts
      invitations: @state.invitations
      leftContacts: @state.leftContacts
      archivedRooms: @state.archivedRooms

  render: ->
    div className: 'launch-fullscreen flex-vert', ref: 'scroll',
      div className: 'header',
        @renderButton()
        @renderClose()
      div className: 'body flex-space thin-scroll',
        div className: 'wrapper',
          @renderTab()
      if @isStory()
        div className: cx('footer', 'is-show': @isValidStoryData()),
          @renderStoryAction()
