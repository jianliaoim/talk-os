searchActions = require '../actions/search'

exports.query = (_teamId, _channelId, _channelType) ->
  #data = {_teamId, _roomId, sort, limit: 20}
  data =
    _teamId: _teamId
    limit: 12
    sort:
      createdAt:
        order: "desc"

  switch _channelType
    when 'room'
      data._roomId = _channelId
    when 'chat'
      data._toId = _channelId
    when 'story'
      data._storyId = _channelId

  searchActions.collectionFile data
  searchActions.collectionLink data
  searchActions.collectionPost data
  searchActions.collectionSnippet data
