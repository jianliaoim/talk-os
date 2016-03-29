# only accept filter or filterNot func.
#
#

exports.byId = (id) ->
  (item, index) ->
    if item.has '_id'
      item.get('_id') is id

exports.byService = (service) ->
  (item, index) ->
    if item.has 'service'
      item.get('service') is service

exports.byNullTarget = (item, index) ->
  item.get('target')?

exports.isHidden = (item) ->
  item.get 'isHidden'

exports.isRobot = (item) ->
  item.has('isRobot') and item.get('isRobot')
