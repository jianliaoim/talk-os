_ = require 'lodash'
Err = require 'err1st'
limbo = require 'limbo'
app = require '../server'

{
  TagModel
} = limbo.use 'talk'

module.exports = tagController = app.controller 'tag', ->

  @mixin require './mixins/permission'

  @ensure 'name', only: 'create update'
  @ensure '_teamId', only: 'create read'

  @before 'isTeamMember', only: 'create read'
  @before 'editableTag', only: 'update remove'

  @action 'create', (req, res, callback) ->
    {name, _teamId, socketId, _sessionUserId} = req.get()
    conditions =
      name: name
      team: _teamId
    TagModel.findOne conditions, (err, tag) ->
      return callback(new Err('OBJECT_EXISTING')) if tag
      tag = new TagModel conditions
      tag.creator = _sessionUserId
      tag.socketId = socketId
      tag.save callback

  @action 'read', (req, res, callback) ->
    {_teamId} = req.get()
    TagModel.find team: _teamId, callback

  @action 'update', (req, res, callback) ->
    {_id, name, tag, socketId} = req.get()
    return callback(null, tag) unless tag.name isnt name
    tag.name = name
    tag.updatedAt = new Date
    tag.socketId = socketId
    tag.save callback

  @action 'remove', (req, res, callback) ->
    {_id, tag, socketId} = req.get()
    tag.socketId = socketId
    tag.remove callback
