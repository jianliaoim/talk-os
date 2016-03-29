
recorder = require 'actions-recorder'

dispatch = recorder.dispatch

# exposed actions

# router

exports.go = (info) -> dispatch 'route/go', info

exports.routeSignIn = -> dispatch 'route/signin'

exports.routeSignUp = -> dispatch 'route/signup'

exports.routeForgotPassword = -> dispatch 'route/forgot-password'

exports.routeSucceedResetting = -> dispatch 'route/succeed-resetting'

exports.routeSucceedBinding = -> dispatch 'route/succeed-binding'

exports.routeEmailSent = -> dispatch 'route/email-sent'

exports.clientAccount = (account) -> dispatch 'client/account', account

exports.clientPassword = (password) -> dispatch 'client/password', password

exports.clientLoading = (status) -> dispatch 'client/loading', status

exports.resetPassword = -> dispatch 'client/reset-password'

exports.routeGo = (info) -> dispatch 'route/go', info

exports.accoutUnbindEmail = -> dispatch 'account/unbind-email'

exports.accoutUnbindMobile = -> dispatch 'account/unbind-mobile'

exports.accountUnbind = (referer) -> dispatch 'account/unbind', referer
