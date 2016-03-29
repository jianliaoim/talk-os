Promise = require 'bluebird'
Err = require 'err1st'
_ = require 'lodash'
limbo = require 'limbo'

util = require '../util'
app = require '../server'

{
  ActivityModel
} = limbo.use 'talk'

module.exports = activityController = app.controller 'activity', ->

  @mixin require './mixins/permission'

  @ensure '_teamId', only: 'read'

  @before 'isTeamMember', only: 'read'
  @before 'deletableActivity', only: 'remove'

  @action 'read', (req, res, callback) ->
    options = _.assign {}, req.get(),
      team: req.get('_teamId')
      user: req.get('_sessionUserId')

    ActivityModel.findByOptions options, callback

  @action 'remove', (req, res, callback) ->
    {activity} = req.get()
    activity.socketId = req.get 'socketId'
    activity.remove callback
