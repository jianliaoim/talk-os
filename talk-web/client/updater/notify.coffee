
exports.create = (store, noticeData) ->
  notices = store.get('notices')
  hasSameText =  notices and notices.find (n) ->
    n.get('text') is noticeData.get('text')

  if hasSameText
    store
  else
    _noticeId = noticeData.get('_id')
    store.setIn ['notices', _noticeId], noticeData

exports.remove = (store, noticeData) ->
  _noticeId = noticeData.get('_id')

  store.deleteIn ['notices', _noticeId]
