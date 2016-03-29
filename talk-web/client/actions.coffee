
recorder = require 'actions-recorder'

config = require './config'

dispatch = recorder.dispatch

# drafts

# settings

exports.markLogin = (status) -> dispatch 'settings/mark-login', status

# device

# misc

exports.outdateStore = ->
  if not config.isGuest
    dispatch 'misc/outdate-store'
