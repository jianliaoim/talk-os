
exports.account = (store, account) ->
  store.setIn ['client', 'account'], account

exports.password = (store, password) ->
  store.setIn ['client', 'password'], password

exports.loading = (store, status) ->
  store.setIn ['client', 'isLoading'], status

exports.resetPassword = (store) ->
  store.setIn ['client', 'password'], ''
