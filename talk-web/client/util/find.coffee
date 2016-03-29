orders = require './orders'

exports.byId = (list, id) ->
  res = list
  .filter (x) -> x._id is id
  res[0]

exports.maxId = (list) ->
  res = list
  .sort orders.imMsgByLargerId
  .map (x) -> x.get('_id')
  res.get(0)

exports.minId = (list) ->
  res = list
  .sort orders.imMsgBySmallerId
  .map (x) -> x.get('_id')
  res.get(0)
