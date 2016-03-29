Promise = require 'bluebird'

app = require '../server'

limbo = require 'limbo'

{
  UserModel
  MobileModel
  EmailModel
  UnionModel
} = limbo.use 'account'

module.exports = userController = app.controller 'user', ->

  @mixin require './mixins/auth'

  @before 'verifyAccount', only: 'get accounts'
  @before 'appendUserDetail', only: 'get'

  ###*
   * 通过 accountToken 获得用户信息
   * @return {Model} user - User model
  ###
  @action 'get', (req, res, callback) ->
    callback null, req.get('user')

  ###*
   * 获取所有绑定账号
   * @return {Array} 绑定的账号和类型
  ###
  @action 'accounts', (req, res, callback) ->
    {user} = req.get()

    $mobile = MobileModel.findOneAsync user: user._id

    $email = EmailModel.findOneAsync user: user._id

    $unions = UnionModel.find user: user._id

    $accounts = Promise.all [$mobile, $email, $unions]

    .spread (mobile, email, unions) ->
      accounts = []
      accounts.push mobile if mobile
      accounts.push email if email
      accounts = accounts.concat unions if unions?.length
      return accounts

    .then (accounts) -> callback null, accounts

    .catch callback
