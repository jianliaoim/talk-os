_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'
logger = require 'graceful-logger'
limbo = require 'limbo'
app = require '../server'

{
  MarkModel
} = limbo.use 'talk'

module.exports = markController = app.controller 'mark', ->

  @mixin require './mixins/permission'

  @ensure '_targetId', only: 'read'

  @before 'readableMarks', only: 'read'
  @before 'deletableMark', only: 'remove'

  @action 'read', (req, res, callback) ->
    {_targetId, story} = req.get()
    conditions =
      target: _targetId
      team: story._teamId
    MarkModel.find conditions, callback

  @action 'remove', (req, res, callback) ->
    {mark, socketId} = req.get()
    mark.socketId = socketId
    mark.$remove().nodeify callback

