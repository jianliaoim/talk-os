recorder = require 'actions-recorder'

TALK = require '../config'

exports.redirectBindEmail = ->
  location.replace "#{TALK.accountUrl}/bind-email?action=bind&next_url=#{window.location}"

exports.redirectChangeEmail = ->
  location.replace "#{TALK.accountUrl}/bind-email?action=change&next_url=#{window.location}"

exports.bind = (newBinding) ->
  recorder.dispatch 'account/bind', newBinding
