React = require 'react'
Immutable = require 'immutable'

LitePopover = React.createFactory require 'react-lite-layered/lib/popover'

TopicName   = React.createFactory require '../app/topic-name'
RosterList = React.createFactory require '../app/roster-list'

UserCorner = React.createFactory require './user-corner'

time = require '../util/time'
lang = require '../locales/lang'

div  = React.createFactory 'div'
span = React.createFactory 'span'

module.exports = React.createClass
  displayName: 'topic-header'

  propTypes:
    topic: React.PropTypes.instanceOf(Immutable.Map).isRequired
    members: React.PropTypes.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    showTopicMenu: false
    showMemberMenu: false
    showMemberManager: false
    showTopicDetail: false
    initialTab: 'topic-configs' # 'topic-settings'

  componentDidMount: ->
    @_nameEl = @refs.name
    @_memberEl = @refs.members

  # custom methods

  getNameArea: ->
    @_nameEl.getBoundingClientRect()

  getMembersArea: ->
    if @refs.members?
      @_memberEl.getBoundingClientRect()
    else
      {}

  normalMembers: (data) ->
    if data.isRobot then return false
    return true

  # event handlers

  onNameCick: ->
    time.nextTick =>
      @setState showTopicMenu: (not @state.showTopicMenu)

  onMembersClick: (event) ->
    event.stopPropagation()
    @setState showMemberMenu: (not @state.showMemberMenu)

  onNameClose: ->     @setState showTopicMenu: false

  onMembersClose: ->  @setState showMemberMenu: false

  onGuestClick: (event) ->
    # parent element has a click acion too
    event.stopPropagation()
    @setState showTopicDetail: true, initialTab: 'topic-settings'

  # renderers

  renderMemberMenu: ->
    LitePopover
      onPopoverClose: @onMembersClose
      baseArea: if @state.showMemberMenu then @getMembersArea() else {}
      showClose: false
      show: @state.showMemberMenu
      RosterList
        _teamId: @props._teamId
        type: 'contact'
        rosters: @props.members.filter(@normalMembers)

  render: ->

    members = @props.members.filter(@normalMembers)

    div className: 'topic-header',
      div ref: 'name', className: 'wrap line', onClick: @onNameCick,
        TopicName
          colorizePlace: 'font'
          topic: @props.topic
          active: false
          onClick: -> # parent element will handle
          showPurpose: true
          showUnread: false
          showGuest: false
      if members.size > 0
        div ref: 'members', className: 'members line', onClick: @onMembersClick,
          span className: 'icon icon-users'
          members.size
      div className: 'divider'
      UserCorner _teamId: @props._teamId
      @renderMemberMenu()
