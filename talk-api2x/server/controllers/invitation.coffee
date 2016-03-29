_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'
limbo = require 'limbo'
app = require '../server'

{
  UserModel
  InvitationModel
} = limbo.use 'talk'

module.exports = invitationController = app.controller 'invitation', ->

  @mixin require './mixins/permission'

  @ensure '_teamId', only: 'read'

  @before 'isTeamMember', only: 'read'
  @before 'editableInvitation', only: 'remove'

  @action 'read', (req, res, callback) ->
    conditions =
      team: req.get '_teamId'
    InvitationModel.find conditions, callback

  @action 'remove', (req, res, callback) ->
    {invitation} = req.get()
    invitation.remove (err, invitation) ->
      callback err, invitation
      res.broadcast "team:#{invitation._teamId}", "invitation:remove", invitation unless err
