Promise = require 'bluebird'
_ = require 'lodash'
path = require 'path'
request = require 'supertest'

BaseMailer = require '../server/mailers/base'
BaseMailer.prototype._send = (email) -> util.checkEmail email

limbo = require 'limbo'
accountDB = limbo.use 'account'
redis = require '../server/components/redis'
app = require '../server/server'

module.exports = util =
  prepare: (done) -> done()

  cleanup: (done) ->
    {collections} = accountDB._conn

    $cleanDB = Promise.resolve Object.keys collections
    .map (collName) ->
      Promise.promisify collections[collName].remove
      .call collections[collName], {}

    $cleanRedis = redis.flushdbAsync()

    Promise.all [$cleanDB, $cleanRedis]
    .then -> done()
    .catch done

  request: (options, callback = ->) ->
    method = options.method?.toLowerCase() or 'get'
    options.body = JSON.stringify(options.body) if toString.call(options.body) is '[object Object]'
    options.headers = _.assign
      "Content-Type": "application/json"
    , options.headers or {}

    request(app)[method] path.join('/v1', options.url)
    .set(options.headers)
    .send options.body or options.qs or {}
    .end (err, res) ->
      {res, body} = res
      if res?.statusCode > 399
        err = new Error(body.message)
        err.data = body.data if body.data
      callback(err, res, body)

  checkEmail: ->

util.requestAsync = Promise.promisify util.request
