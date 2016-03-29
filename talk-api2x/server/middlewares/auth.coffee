Err = require 'err1st'
async = require 'async'
Promise = require 'bluebird'
request = require 'request'
serviceLoader = require 'talk-services'
logger = require 'graceful-logger'
config = require 'config'
redis = require '../components/redis'

limbo = require 'limbo'
{
  UserModel
  TeamModel
} = limbo.use 'talk'

_authService = (req, res, callback) ->
  {appToken} = req.get()
  $service = serviceLoader.getServiceByToken appToken
  $service.then (service) ->
    {robot} = service
    throw new Err('NOT_LOGIN') unless robot?._id
    req.set '_sessionUserId', "#{robot._id}"
    req.robot = robot
  .nodeify callback

_authAccount = (req, res, callback) ->
  {accountToken} = req.get()

  cacheKey = "talkaid:#{accountToken}"
  cacheExpires = 86400

  $user = redis.getAsync cacheKey
  .then (data) ->
    try
      user = JSON.parse data
    catch err
      user = {}
    return user if user?._id
    UserModel.initByAccountTokenAsync accountToken
    .then (user) ->
      return callback(new Err('OBJECT_MISSING', 'user')) unless user?._id
      redis.setexAsync cacheKey, cacheExpires , JSON.stringify(_id: user._id)
      .then -> user

  $setSessionId = $user.then (user) -> req.set '_sessionUserId', user._id if user?._id

  .nodeify callback

auth = (options = {}) ->

  _auth = (req, res, callback = ->) ->
    {appToken} = req.get()
    if appToken?
      # Authorization of service application
      return _authService req, res, callback
    if (req.headers?.authorization and req.headers.authorization.indexOf('aid ') is 0)
      # Transform authorization to accountToken
      [key, token] = req.headers.authorization.split ' '
      req.set 'accountToken', token
    if req.get('accountToken')
      # Authorization of talk account
      return _authAccount req, res, callback
    # Login with access token for the third part websites
    if req.session?._sessionUserId
      callback()
    else
      callback(new Err('NOT_LOGIN'))
  return _auth

module.exports = auth
