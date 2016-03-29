
routerUtil = require 'router-view/lib/path'

module.exports = routerUtil.expandRoutes [
  ['signin', '/signin']
  ['signin', '/access']
  ['signin', '/']
  ['signup', '/signup']
  ['forgot-password', '/forgot-password']
  ['reset-password', '/reset-password'] #?resetToken=:code
  ['succeed-resetting', '/succeed-resetting']
  ['email-sent', '/email-sent']
  ['bind-mobile', '/bind-mobile'] # ?action=change
  ['bind-thirdparty', '/union/callback/:refer'] # ?code=:code
  ['bind-email', '/bind-email'] # ?next_url=:url
  ['verify-email', '/verify-email'] # ?action=:method&verifyToken=:code
  ['succeed-binding', '/succeed-binding']
  ['accounts', '/user/accounts']
  ['404', '~']
]
