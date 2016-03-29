TALK = require '../config'
dispatcher = require '../dispatcher'
NotifyActions = require '../actions/notify'
reqwest = require 'reqwest'

exports.userCreate = (name, email, avatarUrl, success, error) ->
  data = {name, avatarUrl}
  if email then data.email = email
  reqwest
    url: "#{TALK.apiHost}/users/"
    method: 'POST'
    headers:
      'X-Socket-Id': TALK['X-Socket-Id']
    contentType: 'application/json'
    data: JSON.stringify data
    success: (resp) ->
      dispatcher.handleViewAction type: 'user/me', data: resp
      success? resp
    error: (err) ->
      data = JSON.parse err.responseText
      NotifyActions.error data.message
      error? err

exports.roomReadOne = (guestToken, success, error) ->
  reqwest
    url: "#{TALK.apiHost}/rooms/#{guestToken}"
    method: 'GET'
    headers:
      'X-Socket-Id': TALK['X-Socket-Id']
    success: (resp) ->
      dispatcher.handleViewAction type: 'guest-topic/fetch', data: resp
      success? resp
    error: error

exports.roomJoin = (guestToken, success, error) ->
  reqwest
    url: "#{TALK.apiHost}/rooms/#{guestToken}/join"
    method: 'POST'
    headers:
      'X-Socket-Id': TALK['X-Socket-Id']
    success: (resp) ->
      dispatcher.handleViewAction type: 'guest-topic/reset', data: resp
      success? resp
    error: error

exports.roomLeave = (guestToken, success, error) ->
  reqwest
    url: "#{TALK.apiHost}/rooms/#{guestToken}/leave"
    method: 'POST'
    success: (resp) ->
      success? resp
    error: error
