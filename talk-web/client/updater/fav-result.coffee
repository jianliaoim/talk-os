
Immutable = require 'immutable'

exports.read = (store, messagesList) ->
  store
  .update 'favResults', (messages) ->
    messages.concat messagesList

exports.clear = (store, actionData) ->
  store
  .set 'favResults', Immutable.List()
