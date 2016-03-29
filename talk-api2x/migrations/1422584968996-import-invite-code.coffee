{limbo, redis} = require '../lib/components'
util = require '../lib/util'
Promise = require 'bluebird'
{TeamModel} = limbo.use 'talk'

exports.up = (next) ->

  redis.keysAsync 'team:*:invitecode'

  .then (keys) ->

    inviteCodeHash = {}

    redis.mgetAsync keys

    .then (inviteCodes) ->
      for i, key of keys
        [flag, _teamId] = key.split ':'
        continue unless _teamId and inviteCodes[i]
        inviteCodeHash[_teamId] = inviteCodes[i]
      inviteCodeHash

  .then (inviteCodeHash) ->

    TeamModel.findAsync {}

    .map (team) ->
      inviteCode = inviteCodeHash["#{team._id}"]
      if inviteCode and team.inviteCode isnt inviteCode
        team.inviteCode = inviteCode
      else
        team.inviteCode = util.genInviteCode()

      Promise.promisify team.save
      .apply team

  .then -> next()

  .catch next

exports.down = (next) ->
  next()
