Err = require 'err1st'
jwt = require 'jsonwebtoken'
config = require 'config'

authGuest = (options = {}) ->

  _authGuest = (req, res, callback = ->) ->
    try
      user = jwt.verify req.cookies[config.guestSessionKey], config.guestSessionSecret
    catch err

    return callback(new Err('NOT_LOGIN')) unless user?._id
    req.set '_sessionUserId', user._id
    callback()

module.exports = authGuest
