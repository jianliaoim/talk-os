
dispatcher = require '../dispatcher'

time = require '../util/time'

exports.update = (data) ->
  dispatcher.handleViewAction
    type: 'settings/update'
    data: data

exports.teamFootprints = (_teamId) ->
  dispatcher.handleViewAction
    type: 'settings/team-footprints'
    data:
      _teamId: _teamId
      time: time.unix()

exports.foldContact = (_contactId, _teamId) ->
  dispatcher.handleViewAction
    type: 'settings/fold-contact'
    data:
      _teamId: _teamId
      _id: _contactId

exports.unfoldContact = (_contactId, _teamId) ->
  dispatcher.handleViewAction
    type: 'settings/unfold-contact'
    data:
      _teamId: _teamId
      _id: _contactId

exports.openDrawer = (type) ->
  dispatcher.handleViewAction
    type: 'settings/open-drawer'
    data:
      type: type

exports.closeDrawer = ->
  dispatcher.handleViewAction
    type: 'settings/close-drawer'

exports.changeEnterMethod = (method) ->
  dispatcher.handleViewAction
    type: 'settings/change-enter-method'
    data: method

exports.updateEmojiCounts = (emoji) ->
  dispatcher.handleViewAction
    type: 'settings/update-emoji-counts'
    data: emoji
