
exports.fetch = (store, actionData) ->
  store.set 'accounts', actionData

exports.unbind = (store, actionData) ->
  store.update 'accounts', (accounts) ->
    accounts.filterNot (account) ->
      account.get('login') is actionData.get('refer')

exports.unbindEmail = (store, actionData) ->
  store.update 'accounts', (accounts) ->
    accounts.filterNot (account) ->
      account.get('login') is 'email'

exports.bind = (store, newBinding) ->
  targetBinding = store.get('accounts').find (binding) ->
    binding.get('refer') is newBinding.get('refer')

  store.update 'accounts', (cursor) ->
    if targetBinding?
      cursor.map (binding) ->
        if binding.get('refer') is newBinding.get('refer')
          binding.merge newBinding
        else binding
    else cursor.push newBinding
