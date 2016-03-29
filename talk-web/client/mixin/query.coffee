###
 * Mixins for generally query method,
 * after import this mixin,
 * you may not have to specific "_teamId" into propTypes.
###

React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'

T = React.PropTypes

module.exports =

  propTypes:
    _teamId: T.string.isRequired

  getTeam: ->
    query.teamBy recorder.getState(), @props._teamId

  getTeams: ->
    query.teams recorder.getState()

  getRooms: ->
    query.orList query.topicsBy recorder.getState(), @props._teamId

  getGroups: ->
    query.orList query.groupsBy recorder.getState(), @props._teamId

  getContacts: ->
    query.orList query.contactsBy recorder.getState(), @props._teamId

  getInvitations: ->
    query.orList query.invitationsBy recorder.getState(), @props._teamId

  getLeftContacts: ->
    query.orList query.leftContactsBy recorder.getState(), @props._teamId

  getArchivedRooms: ->
    query.orList query.archivedTopicsBy recorder.getState(), @props._teamId

  getNotifications: ->
    query.orList query.notificationsBy recorder.getState(), @props._teamId

  getContactAlias: (_id) ->
    query.contactAliasBy(recorder.getState(), @props._teamId, _id)

  getMentionedMessages: ->
    query.orList query.mentionedMessagesBy recorder.getState(), @props._teamId
