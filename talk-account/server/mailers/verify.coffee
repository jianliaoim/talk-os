_ = require 'lodash'

BaseMailer = require './base'
util = require '../util'
debug = require('debug')('talk:verbose')

class ResetPasswordMailer extends BaseMailer

  delay: 0
  action: 'send'
  template: 'verify'

  send: (verifyData, emailAddress) ->
    email =
      id: "verify_#{emailAddress}"
      to: emailAddress
      subject: "[简聊] 验证邮件"

    email = _.assign email, verifyData
    email.verifyUrl = util.buildVerifyEmailUrl verifyData

    debug email

    @_sendByRender email

  preview: (callback) ->
    email =
      subject: "[简聊] 验证邮件"
      emailAddress: 'user@mailer.com'
      verifyCode: '1234'
      verifyUrl: 'https://jianliao.com/site'
    super email, callback

module.exports = new ResetPasswordMailer
