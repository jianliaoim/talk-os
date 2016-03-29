React = require 'react'
assign = require 'object-assign'
Immutable = require 'immutable'

draftActions = require '../actions/draft'

FormFile = React.createFactory require './form-file'
FormLink = React.createFactory require './form-link'
FormTopic = React.createFactory require './form-topic'
PanelChat = React.createFactory require './panel-chat'
PanelRoom = React.createFactory require './panel-room'
MembersRow = React.createFactory require '../app/members-row'

{ div, noscript } = React.DOM
T = React.PropTypes

STORY_TYPES = [ 'file', 'link', 'topic' ]

module.exports = React.createClass
  displayName: 'launch-tabpage'

  propTypes:
    _teamId: T.string.isRequired
    _userId: T.string.isRequired
    data: T.instanceOf Immutable.Map
    tabKey: T.string.isRequired
    onChange: T.func
    onClose: T.func
    formDatum: T.instanceOf Immutable.Map
    rooms: T.instanceOf Immutable.List
    contacts: T.instanceOf Immutable.List
    invitations: T.instanceOf Immutable.List
    leftContacts: T.instanceOf Immutable.List
    archivedRooms: T.instanceOf Immutable.List

  onChange: (key, value) ->
    draftActions.updateStoryDraft @props._teamId, @props.tabKey, { key, value }

  render: ->

    formProps = =>
      data: @props.data.get 'data'
      onChange: (data) => @onChange 'data', data
      displayMode: 'create'

    div className: 'launch-tabpage',
      switch @props.tabKey
        when 'file' then FormFile formProps()
        when 'link' then FormLink formProps()
        when 'topic' then FormTopic formProps()
        when 'chat'
          PanelChat
            _teamId: @props._teamId
            contacts: @props.contacts
            leftContacts: @props.leftContacts
        when 'room'
          PanelRoom
            _teamId: @props._teamId
            rooms: @props.rooms
            onClose: @props.onClose
            archivedRooms: @props.archivedRooms

      if @props.tabKey in STORY_TYPES
        MembersRow
          _teamId: @props._teamId
          _memberIds: @props.data.get('_memberIds') or Immutable.List [ @props._userId ]
          contacts: @props.contacts
          onChange: (data) => @onChange '_memberIds', data
          isEditable: true
      else noscript()
