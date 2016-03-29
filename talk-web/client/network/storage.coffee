recorder = require 'actions-recorder'
Immutable = require 'immutable'

schema = require '../schema'
actions = require '../actions'

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
  return if (typeof window.localStorage) is 'undefined'

  store = recorder.getState()
  data = purifyStore(store)

  if store.getIn(['settings', 'isLoggedIn'])
    window.localStorage.setItem newVersion, JSON.stringify(data)
  else
    window.localStorage.removeItem newVersion

exports.get = ->
  return Immutable.Map() if (typeof window.localStorage) is 'undefined'

  jianliaoStoreString =
    try
      JSON.parse(window.localStorage.getItem(newVersion))
    catch
      null

  if jianliaoStoreString?
    Immutable.fromJS(jianliaoStoreString)
  else
    Immutable.Map()
