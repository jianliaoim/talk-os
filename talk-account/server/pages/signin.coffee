limbo = require 'limbo'
Promise = require 'bluebird'

app = require '../server'

{UserModel, MobileModel, EmailModel, UnionModel} = limbo.use 'account'

renderer = require '../../client/entry/renderer'

module.exports = signInController = app.controller 'signin', ->

  @action 'redirect', (req, res, callback) ->
    res.redirect '/account/signin'

  @action 'render', (req, res, callback) ->
    {accountToken} = req.get()

    if not accountToken?
      renderer req, res
      return

    UserModel.verifyAccountToken accountToken, (err, user) ->
      if err?
        renderer req, res
        return
      $mobile = MobileModel.findOneAsync user: user._id
      $email = EmailModel.findOneAsync user: user._id
      $unions = UnionModel.find user: user._id
      $accounts = Promise.all [$mobile, $email, $unions]

      $accounts
      .spread (mobile, email, unions) ->
        user.phoneNumber = mobile.phoneNumber if mobile?.phoneNumber
        user.emailAddress = email.emailAddress if email?.emailAddress
        user.unions = unions if unions?.length
        return user
      .then (user) ->
        req.set 'user', user
        renderer req, res
      .catch ->
        renderer req, res
