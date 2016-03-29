request = require 'request'
Promise = require 'bluebird'
requestAsync = Promise.promisify request
debug = require('debug')('talk:verbose')
config = require 'config'
Err = require 'err1st'

module.exports = requestUtil =
  sendSMS: (options) ->
    # @osv
    return
    debug options
    return if process.env.DEBUG
    {phoneNumber, ip, _userId, refer, msg, uid} = options
    _options =
      method: 'POST'
      url: config.sms.host + '/send'
      json: true
      body:
        key: config.sms.key
        secret: config.sms.secret
        phone: phoneNumber
        ip: ip
        _userId: _userId
        refer: refer
        msg: msg
        uid: uid
    requestAsync _options
    .spread (res, body) ->
      throw new Err('SEND_SMS_ERROR') unless res?.statusCode is 200
      body
