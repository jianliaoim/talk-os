
routerUtil = require 'router-view/lib/path'

module.exports = routerUtil.expandRoutes [
  ['signin', '/account/signin']
  ['signin', '/account/access']
  ['signin', '/account']
  ['signup', '/account/signup']
  ['forgot-password', '/account/forgot-password']
  ['reset-password', '/account/reset-password'] #?resetToken=:code
  ['succeed-resetting', '/account/succeed-resetting']
  ['email-sent', '/account/email-sent']
  ['bind-mobile', '/account/bind-mobile'] # ?action=change
  ['bind-thirdparty', '/account/union/callback/:refer'] # ?code=:code
  ['bind-email', '/account/bind-email'] # ?next_url=:url
  ['verify-email', '/account/verify-email'] # ?action=:method&verifyToken=:code
  ['succeed-binding', '/account/succeed-binding']
  ['accounts', '/account/user/accounts']
  ['404', '/account/~']
]
