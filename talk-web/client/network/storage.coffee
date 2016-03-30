Store = require 'store2'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

newVersion = 'jianliaoStoreV3'

purifyStore = (store) ->
  drafts = store.get('drafts')
    .update 'draft', (draft) ->
      if draft
        draft.filter (v) -> v
      else
        draft

  drafts: drafts.toJS()
  settings: store.get('settings').toJS()

window.addEventListener 'beforeunload', ->
  store = recorder.getState()
  data = purifyStore(store)

  if store.getIn(['settings', 'isLoggedIn'])
    Store.set newVersion, data
  else
    Store.remove newVersion

exports.get = ->
  data = Store.get(newVersion) or {}
  Immutable.fromJS(data)
