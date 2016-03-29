
exports.after = (store, messagesList) ->
  store.update 'searchMessages', (messages) ->
    messages.concat messagesList

exports.before = (store, messagesList) ->
  store.update 'searchMessages', (messages) ->
    messagesList.concat messages

exports.search = (store, messagesList) ->
  store.set 'searchMessages', messagesList
