Promise = require 'bluebird'
Err = require 'err1st'
config = require 'config'

app = require '../server'
redis = require '../components/redis'

limbo = require 'limbo'

{
  UserModel
} = limbo.use 'talk'

module.exports = checkController = app.controller 'check', ->

  @action 'ping', (req, res, callback) ->
    return callback(new Err('PARAMS_INVALID', 'checkToken')) unless req.query.checkToken is config.checkToken
    # Db state
    $dbState = UserModel.findOneAsync()

    # Redis state
    $redisState = redis.setexAsync "ping:api", 3600, Date.now()

    Promise.all [$dbState, $redisState]
    .then -> callback null, ok: 1
    .catch callback
