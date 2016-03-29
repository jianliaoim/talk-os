validator = require 'validator'
phone = require 'phone'
Err = require 'err1st'
app = require '../server'

req = app.request

req.allowedKeys = [
  'accountToken', 'action',
  'bindCode',
  'code',
  'emailAddress',
  'lang',
  'method',
  'next_url', 'newPassword',
  'password', 'phoneNumber',
  'randomCode',
  'refer', 'resetToken',
  'showname',
  'token',
  'verifyCode', 'verifyToken',
  'oauth_token', 'oauth_verifier',
  'uid'
]

req.alias =
  aid: 'accountToken'
  bid: 'bindCode'
  vid: 'randomCode'
  resettoken: 'verifyToken'

req.setters =
  phoneNumber: (phoneNumber) ->
    if /^1[0-9]{10}$/.test phoneNumber
      phoneNumber = '+86' + phoneNumber
    [phoneNumber] = phone phoneNumber
    # 国内手机不保留区号
    if phoneNumber?
      phoneNumber = phoneNumber[3..] if phoneNumber[0...3] is '+86'
      throw new Err 'PARAMS_INVALID', 'phoneNumber' unless phoneNumber.length
      return phoneNumber
    else throw new Err 'PARAMS_INVALID', 'phoneNumber'
  emailAddress: (emailAddress) ->
    return emailAddress.trim() if validator.isEmail emailAddress
    throw new Err 'PARAMS_INVALID', 'emailAddress'
  password: (password) ->
    return password.trim() if toString.call(password) is '[object String]' and password.length >= 6
    throw new Err 'PASSWORD_TOO_SIMPLE'
  newPassword: (password) ->
    return password.trim() if toString.call(password) is '[object String]' and password.length >= 6
    throw new Err 'PASSWORD_TOO_SIMPLE'
