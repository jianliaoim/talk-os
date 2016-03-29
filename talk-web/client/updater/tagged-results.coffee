
Immutable = require 'immutable'

exports.read = (store, actionData) ->
  messagesList = actionData.get('messages')

  store.update 'taggedResults', (messages) ->
    messages.concat messagesList

exports.clear = (store, actionData) ->
  store.set 'taggedResults', Immutable.List()
