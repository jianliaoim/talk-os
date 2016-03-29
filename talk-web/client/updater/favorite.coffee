
Immutable = require 'immutable'

# https://jianliao.com/doc/restful/favorite.read.html
exports.read = (store, messagesList) ->
  _teamId = store.getIn(['device', '_teamId'])

  store.setIn ['favorites', _teamId], messagesList

# https://jianliao.com/doc/restful/favorite.remove.html
exports.remove = (store, messageData) ->
  _teamId = messageData.get('_teamId')
  _messageId = messageData.get('_id')
  inCollection = (message) -> message.get('_id') is _messageId

  store
  .updateIn ['favorites', _teamId], (messages) ->
    if messages?
      messages.filterNot inCollection
    else Immutable.List()
  .update 'favResults', (messages) ->
    if messages.some(inCollection)
      messages.filterNot inCollection
    else messages

exports.create = (store, messageData) ->
  _teamId = messageData.get('_teamId')
  _messageId = messageData.get('_id')
  inCollection = (message) -> message.get('_id') is _messageId

  store
  .updateIn ['favorites', _teamId], (messages) ->
    if messages?
      messages.unshift messageData
    else Immutable.List [messageData]
  .update 'favResults', (messages) ->
    messages.filterNot(inCollection).unshift messageData
