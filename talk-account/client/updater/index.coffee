
route = require './route'
client = require './client'
account = require './account'

identity = (x) -> x

module.exports = (store, actionType, actionData) ->

  handler = switch actionType
    when 'route/signin' then route.signin
    when 'route/signup' then route.signup
    when 'route/forgot-password' then route.forgotPassword
    when 'route/email-sent' then route.emailSent
    when 'route/succeed-resetting' then route.succeedResetting
    when 'route/succeed-binding' then route.succeedBinding
    when 'route/reset-password' then route.resetPassword
    when 'route/go' then route.go

    when 'client/account' then client.account
    when 'client/password' then client.password
    when 'client/loading' then client.loading
    when 'client/reset-password' then client.resetPassword

    when 'account/unbind-email' then account.unbindEmail
    when 'account/unbind-mobile' then account.unbindMobile
    when 'account/unbind' then account.unbind

    else identity

  handler store, actionData
