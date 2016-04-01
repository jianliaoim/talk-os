recorder = require 'actions-recorder'

dataRely = require '../network/data-rely'

lang = require '../locales/lang'
dispatcher = require '../dispatcher'
notifyActions = require '../actions/notify'
routerHanlders = require './router'

# http://talk.ci/doc/event/team.leave.html
exports.leave = (removeEvent) ->
  _teamId = removeEvent.get('_teamId')
  _contactId = removeEvent.get('_userId')

  store = recorder.getState()
  _userId = store.getIn(['user', '_id'])
  teamData = store.getIn(['teams', _teamId])

  if _contactId is _userId
    routerHanlders.settingTeams()

    warningText = lang.getText('removed-from-team-%s')
    .replace '%s', teamData.get('name')
    notifyActions.warn warningText

  dispatcher.handleServerAction
    type: 'team/leave'
    data: removeEvent

exports.channels = (_teamId, cb) ->
  d = dataRely.ensure [
    dataRely.relyTeamTopics(_teamId)
    dataRely.relyTeamMembers(_teamId)
  ]

  d.request().then(cb).done()
