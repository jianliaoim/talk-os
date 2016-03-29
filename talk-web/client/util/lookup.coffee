exports.getMessageChannelId = (messageData, _userId) ->
  _roomId = messageData.get('_roomId')
  _storyId = messageData.get('_storyId')
  _toId = messageData.get('_toId')
  _creatorId = messageData.get('_creatorId')
  isMe = _toId is _userId
  _roomId or _storyId or (if isMe then _creatorId else _toId)

exports.getChannelId = (channelData) ->
  _toId = channelData.get '_toId'
  _roomId = channelData.get '_roomId'
  _storyId = channelData.get '_storyId'

  _toId or _roomId or _storyId

exports.getChannelType = (channelData) ->
  if channelData.has('_toId')
    'chat'
  else if channelData.has('_roomId')
    'room'
  else if channelData.has('_storyId')
    'story'
  else
    throw Error 'undefined channel type'
