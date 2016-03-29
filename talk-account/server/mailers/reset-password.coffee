_ = require 'lodash'
debug = require('debug')('talk:verbose')

BaseMailer = require './base'
util = require '../util'

class ResetPasswordMailer extends BaseMailer

  delay: 0
  action: 'send'
  template: 'reset-password'

  send: (verifyData, emailAddress) ->
    email =
      id: "resetpassword_#{emailAddress}"
      to: emailAddress
      subject: "[简聊] 密码重置"

    email = _.assign email, verifyData
    email.resetUrl = util.buildResetPasswordUrl verifyData

    debug email

    @_sendByRender email

  preview: (callback) ->
    email =
      subject: "[简聊] 密码重置"
      emailAddress: 'user@mailer.com'
      verifyCode: '1234'
      resetUrl: 'https://jianliao.com/site'
    super email, callback

module.exports = new ResetPasswordMailer
