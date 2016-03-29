
Immutable = require 'immutable'

# dataSchame =
#   _teamId: {type: 'string'}
#   resp: {type: 'array'}
exports.fetch = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  inteList = actionData.get('resp')

  store.setIn ['intes', _teamId], inteList

exports.create = (store, inteData) ->
  _teamId = inteData.get('_teamId')

  store.updateIn ['intes', _teamId], (intes) ->
    if intes?
      intes.push inteData
    else
      Immutable.List [inteData]

exports.remove = (store, inteData) ->
  _teamId = inteData.get('_teamId')
  _inteId = inteData.get('_id')

  if store.getIn('intes', _teamId)?
    store.updateIn ['intes', _teamId], (intes) ->
      intes.filterNot (inte) ->
        inte.get('_id') is _inteId
  else store

exports.update = (store, inteData) ->
  _teamId = inteData.get('_teamId')
  _inteId = inteData.get('_id')

  if store.getIn('intes', _teamId)?
    store.updateIn ['intes', _teamId], (intes) ->
      intes.map (inte) ->
        if inte.get('_id') is _inteId
          inte.merge inteData
        else inte
  else store

exports.settings = (store, settings) ->
  store.set 'inteSettings', settings
