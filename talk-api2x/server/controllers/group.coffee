_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'
logger = require 'graceful-logger'
limbo = require 'limbo'
app = require '../server'

{
  GroupModel
} = limbo.use 'talk'

module.exports = groupController = app.controller 'group', ->

  editableFields = ['addMembers', 'removeMembers', 'name']

  @mixin require './mixins/permission'

  @ensure '_teamId', only: 'read'
  @ensure 'name _memberIds', only: 'create'

  @least editableFields, only: 'update'

  @before 'isTeamMember', only: 'read'
  @before 'isTeamAdmin', only: 'create'

  @before 'editableGroup', only: 'update remove'

  @action 'read', (req, res, callback) ->
    {_teamId} = req.get()
    GroupModel.find team: _teamId, callback

  @action 'create', (req, res, callback) ->
    options =
      creator: req.get '_sessionUserId'
      team: req.get '_teamId'
      name: req.get 'name'
      members: req.get '_memberIds'
    group = new GroupModel options
    group.socketId = req.get('socketId')
    group.$save().nodeify callback

  @action 'update', (req, res, callback) ->
    {group} = req.get()
    update = _.pick req.get(), editableFields

    if update.addMembers?.length
      group.members = _.uniq group.members.concat(update.addMembers)

    if update.removeMembers?.length
      group.members = group.members.filter (_memberId) -> "#{_memberId}" not in update.removeMembers

    group[key] = val for key, val of update

    group.socketId = req.get('socketId')
    group.updatedAt = new Date
    group.$save().nodeify callback

  @action 'remove', (req, res, callback) ->
    {group} = req.get()
    group.socketId = req.get('socketId')
    group.$remove().nodeify callback
