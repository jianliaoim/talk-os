# func name start with 'by' is for sortBy
# func name start with 'with' is for sort
# func name start with 'is' is special case
#
#

exports.byId = (targetId, reverse) ->
  (item) ->
    isTarget = item.get('_id') is targetId
    if reverse
      return not isTarget

    return isTarget

exports.byName = (item) ->
  item.has('name') and item.get('name')

exports.byPinyin = (item, index) ->
  item.has('pinyin') and item.get('pinyin')

exports.byRobot = (item) ->
  item.has('isRobot') and item.get('isRobot')

exports.byUpdatedAt = (item, index) ->
  new Date() - new Date(item.get('updatedAt'))

exports.isIncluded = (collection) ->
  (item, index) ->
    inCollection = (cursor) -> cursor is item.get('_id')
    not collection.some inCollection

exports.isGeneral = (item, index) ->
  not (item.has('isGeneral') and item.get('isGeneral'))

exports.isPinned = (item, index) ->
  not (item.has('isPinned') and item.get('isPinned'))

exports.isTalkai = (item, index) ->
  not (item.has('service') and item.get('service') is 'talkai')

exports.isUser = (userId) ->
  (item, index) ->
    not (item.has('_id') and item.get('_id') is userId)
