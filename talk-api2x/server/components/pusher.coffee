# @osv
return module.exports = {}

pusher = require 'node-push'
config = require 'config'

pusherConfig = config.pusher
pusher.configure pusherConfig

module.exports = pusher
