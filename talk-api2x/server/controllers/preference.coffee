_ = require 'lodash'
limbo = require 'limbo'
{PreferenceModel} = limbo.use 'talk'

app = require '../server'

module.exports = preferenceController = app.controller 'preference', ->

  @action 'readOne', (req, res, callback) ->
    {_sessionUserId} = req.get()
    PreferenceModel.findOne _id: _sessionUserId, (err, preference) ->
      return callback(err, preference) if preference
      PreferenceModel.updateByUserId _sessionUserId, {}, callback

  @action 'update', (req, res, callback) ->
    {_sessionUserId} = req.get()
    conditions = _id: _sessionUserId
    fields = [
      'desktopNotification'
      'emailNotification'
      'hasShownTips'
      'hasShownRichTextTips'
      'language'
      'notifyOnRelated'
      'displayMode'
      '_latestTeamId'
      '_latestRoomId'
      'customOptions'
      'muteWhenWebOnline'
      'webData'
      'timezone'
      'pushOnWorkTime'
    ]
    if req.get('pushOnWorkTime')
      return callback(new Err('PARAMS_MISSING', 'timezone')) unless req.get('timezone')

    update = _.pick req.get(), fields
    PreferenceModel.updateByUserId _sessionUserId
    , update
    , callback
