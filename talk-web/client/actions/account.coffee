dispatcher = require '../dispatcher'

api = require '../network/api'
TALK = require '../config'

exports.bind = (refer) ->
  if refer is 'mobile'
    location.replace "#{ TALK.accountUrl }/bind-mobile?action=bind&next_url=#{ window.location }"
  else if refer?.length
    location.replace "#{ TALK.accountUrl }/union/#{ refer }?next_url=#{ window.location }&method=bind"

exports.change = (refer) ->
  if refer is 'mobile'
    location.replace "#{ TALK.accountUrl }/bind-mobile?action=change&next_url=#{ window.location }"

exports.unbindEmail = (email) ->
  api.post("/api/account/email/unbind/", emailAddress: email)
  .then (resp) ->
    dispatcher.handleViewAction
      type: 'account/unbind-email'
      data: email

exports.fetch = (success, fail) ->
  api.get '/api/account/user/accounts'
  .then (resp) ->
    dispatcher.handleViewAction
      type: 'account/fetch'
      data: resp
    success? resp
  .catch (error) ->
    fail? error

exports.unbind = (refer, success, fail) ->
  api.post "/api/account/union/unbind/#{ refer }"
  .then (resp) ->
    dispatcher.handleViewAction
      type: 'account/unbind'
      data: refer: refer
    success? resp
  .catch (error) ->
    fail? error
