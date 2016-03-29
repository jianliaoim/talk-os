config = require 'config'
Err = require 'err1st'
serializer = require 'serializer'
qs = require 'querystring'

module.exports = urlUtil =
  buildCallbackUrl: (refer) -> config.accountUrl + "/union/callback/#{refer}"

  buildResetPasswordUrl: (verifyData) ->
    {randomCode, verifyCode} = verifyData
    resetToken = serializer.secureStringify
      randomCode: randomCode
      verifyCode: verifyCode
    , config.accountCookieSecret
    config.accountUrl + "/reset-password?resetToken=" + encodeURIComponent resetToken

  buildVerifyEmailUrl: (verifyData) ->
    {randomCode, verifyCode} = verifyData
    verifyToken = serializer.secureStringify
      randomCode: randomCode
      verifyCode: verifyCode
    , config.accountCookieSecret
    qsParams =
      verifyToken: verifyToken
      action: verifyData.action
    config.accountUrl + "/verify-email?" + qs.stringify qsParams

  parseVerifyToken: (verifyToken, callback) ->
    try
      verifyData = serializer.secureParse verifyToken, config.accountCookieSecret
    catch err
      return callback new Err('PARAMS_INVALID', 'verifyToken')

    callback null, verifyData
