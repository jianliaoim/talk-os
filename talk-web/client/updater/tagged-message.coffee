
exports.read = (store, messagesList) ->
  store.set 'taggedMessages', messagesList.filter (message) ->
    maybeTags = message.get('tags')
    maybeTags and maybeTags.size > 0
