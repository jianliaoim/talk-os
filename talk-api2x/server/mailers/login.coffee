async = require 'async'
Err = require 'err1st'
BaseMailer = require './base'
util = require '../util'
logger = require '../components/logger'

class LoginMailer extends BaseMailer

  delay: 0
  action: 'send'
  template: 'login'

  send: (user) ->

    self = this

    email =
      id: "login#{user._id}"
      user: user
      to: user.emailForLogin
      subject: "[简聊] 欢迎来到简聊"

    email.redirectTip = '点击按钮访问简聊：'
    email.redirectBtnTip = '访问简聊'
    email.redirectUrl = util.buildIndexUrl()

    self._sendByRender email

module.exports = new LoginMailer
