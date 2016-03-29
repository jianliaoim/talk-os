
pathUtil = require 'router-view/lib/path'

module.exports = pathUtil.expandRoutes [
  ['home',      '/']
  ['room',      '/rooms/:token']
  ['disabled',  '/disabled']
  ['signup',    '/signup']
  ['404',       '~']
]
