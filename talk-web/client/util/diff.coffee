exports.adds = (prev, next) ->
  arr = []
  next.forEach (nextItem) ->
    if not prev.some((prevItem) -> prevItem is nextItem)
      arr.push nextItem
  arr

exports.removes = (prev, next) ->
  arr = []
  prev.forEach (prevItem) ->
    if not next.some((nextItem) -> nextItem is prevItem)
      arr.push prevItem
  arr

# Immutable
exports.toggle = (imList, targetItem) ->
  if imList.contains targetItem
    imList.filterNot (item) ->
      item is targetItem
  else
    imList.push targetItem
