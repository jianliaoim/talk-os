_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'

limbo = require 'limbo'
{
  UserModel
} = limbo.use 'talk'

module.exports = generalMixin =
  # Set sessionUser property
  setSessionUser: (req, res, callback) ->
    {_sessionUserId} = req.get()
    UserModel.findOne _id: _sessionUserId, (err, user) ->
      return callback(new Err('NOT_LOGIN')) unless user
      req.set 'sessionUser', user
      callback()
