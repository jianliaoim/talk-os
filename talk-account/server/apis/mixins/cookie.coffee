config = require 'config'

module.exports = cookieMixin =
  setCookie: (req, res, user, callback) ->
    cookieOptions =
      domain: config.cookieDomain
      expires: new Date(Date.now() + config.accountCookieExpires * 1000)
      httpOnly: true
    res.cookie config.accountCookieId, user.accountToken, cookieOptions
    callback null, user
