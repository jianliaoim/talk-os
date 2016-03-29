
exports.unbindEmail = (store) ->
  store.setIn ['page', 'accounts', 'emailAddress'], null

exports.unbindMobile = (store) ->
  store.setIn ['page', 'accounts', 'phoneNumber'], null

exports.unbind = (store, refer) ->
  store.updateIn ['page', 'accounts', 'unions'], (bindings) ->
    bindings.filterNot (binding) ->
      binding.get('refer') is refer
