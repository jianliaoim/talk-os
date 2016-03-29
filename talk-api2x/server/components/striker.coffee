# @osv
return module.exports =
  signAuth: -> 'token'
  downloadUrl: -> ''
  previewUrl: -> ''
  thumbnailUrl: -> ''

StrikerUtil = require 'striker-util'
config = require 'config'

module.exports = strikerUtil = new StrikerUtil
  host: config.strikerHost
  storage: config.strikerStorage
  secretKeys: config.strikerAuth
  expiresInSeconds: 3600 * 48
