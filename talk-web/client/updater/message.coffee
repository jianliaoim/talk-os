config = require '../config'
lookup = require '../util/lookup'

Immutable = require 'immutable'
# data with array of messages:
# http://talk.ci/doc/restful/message.read.html
# dataSchema =
#   type: 'object'
#   channel:
#     type: 'object'
#     properties:
#       _teamId: {type: 'string'}
#       _toId: {type: 'string'}
#       _roomId: {type: 'string'}
#   data:
#     type: 'array'
#     items: {} # complicated
exports.more = (store, actionData) ->
  messageListData = actionData.get('data')
  _teamId = actionData.get('channel').get('_teamId')
  _channelId = lookup.getChannelId actionData.get('channel')

  store.update 'messages', (messagesEntry) ->
    if messagesEntry.getIn([_teamId, _channelId])?
      messagesEntry
      .updateIn [_teamId, _channelId], (messages) ->
        existedIds = messages.map (message) ->
          message.get('_id')
        newMessageList = messageListData.filter (message) ->
          not existedIds.contains(message.get('_id'))
        messages
        .concat newMessageList
        .sortBy (message) -> message.get('createdAt')
    else if messagesEntry.get(_teamId)?
      sortedMessages = messageListData.sortBy (message) -> message.get('createdAt')
      messagesEntry
      .setIn [_teamId, _channelId],sortedMessages
    else
      sortedMessages = messageListData.sortBy (message) -> message.get('createdAt')
      messagesEntry
      .set _teamId, Immutable.Map().setIn(_channelId, sortedMessages)

# message object: http://talk.ci/doc/event/message.create.html
exports.create = (store, messageData) ->
  _toId = messageData.get('_toId')
  _roomId = messageData.get('_roomId')
  _teamId = messageData.get('_teamId')
  _userId = store.getIn ['user', '_id']
  _storyId = messageData.get('_storyId')
  _creatorId = messageData.get('_creatorId')
  _messageId = messageData.get('_id')
  _channelId = lookup.getMessageChannelId(messageData, _userId)
  isMe = _creatorId is _userId
  isSystem = messageData.get('isSystem')
  createdAt = messageData.get('createdAt')
  isRelated = _userId in [_toId, _creatorId]
  inCollection = (message) -> message.get('_id') is _messageId

  store
  .update 'messages', (cursor) ->
    if cursor.getIn([_teamId, _channelId])?
      cursor.updateIn [_teamId, _channelId], (messages) ->
        if messages.some(inCollection)
          messages
          .map (message) ->
            if message.get('_id') is _messageId
              message.merge messageData
            else message
        else
          messages
          .push messageData
    else cursor
  .update 'topics', (cursor) ->
    if _roomId? and cursor.get(_teamId)?
      cursor.update _teamId, (rooms) ->
        rooms.map (room) ->
          if room.get('_id') is _roomId
            if not messageData.get('isSystem')
              if messageData.get('_creatorId') is _userId
                room.set 'lastActive', createdAt
              else
                # dirty code to support old style api in guest page
                if config.isGuest
                  room.set('lastActive', createdAt).update 'unread', (unread) -> unread + 1
                else
                  room.set 'lastActive', createdAt
            else room
          else room
    else cursor
  .update 'contacts', (cursor) ->
    if _toId? and isRelated and cursor.get(_teamId)?
      cursor.update _teamId, (contacts) ->
        contacts.map (contact) ->
          if (contact.get('_id') is _channelId) and (not isSystem)
            if messageData.get('_toId') is _userId
              contact
              .set 'lastActive', createdAt
            else contact.set('lastActive', createdAt)
          else contact
    else cursor
  .update 'stories', (cursor) ->
    if _storyId? and cursor.has(_teamId)
      cursor.update _teamId, (stories) ->
        stories.map (story) ->
          if story.get('_id') is _storyId
            if not messageData.get('isSystem')
              if messageData.get('_creatorId') is _userId
                story.set 'lastActive', createdAt
              else
                story
                .set 'lastActive', createdAt
            else story
          else story
    else cursor

# part of a message object:
# http://talk.ci/doc/event/message.remove.html
# dataSchema =
#   type: 'object'
#   properties:
#     _teamId: {type: 'string'}
#     _id: {type: 'string'}
#     _roomId: {type: 'string'}
#     _toId: {type: 'string'}
exports.remove = (store, messageDatum) ->

  _id = messageDatum.get('_id')
  _teamId = messageDatum.get('_teamId')
  _channelId = lookup.getMessageChannelId messageDatum, store.getIn ['user', '_id']

  inCollection = (item) -> item.get('_id') is _id
  notInCollection = (item) -> item.get('_id') isnt _id

  isRemoved = (messages) ->
    if messages? and messages.some inCollection
      messages.filterNot (message) ->
        message.get('_id') is _id
    else messages

  isCursorRemoved = (cursor) ->
    cursor.map (innerCursor) ->
      innerCursor.map isRemoved

  store
  .update 'messages', (cursor) ->
    if cursor.hasIn [_teamId, _channelId]
      cursor.updateIn [_teamId, _channelId], (messages) ->
        messages.filter notInCollection
    else cursor
  .update 'taggedMessages', isRemoved
  .update 'taggedResults', isRemoved
  .update 'fileMessages', isCursorRemoved
  .update 'postMessages', isCursorRemoved
  .update 'linkMessages', isCursorRemoved
  .update 'snippetMessages', isCursorRemoved

# message object: http://talk.ci/doc/event/message.update.html
exports.update = (store, messageData) ->
  _teamId = messageData.get('_teamId')
  _messageId = messageData.get('_id')
  _roomId = messageData.get('_roomId')
  _toId = messageData.get('_toId')
  _userId = store.getIn ['user', '_id']
  _channelId = lookup.getMessageChannelId(messageData, _userId)
  inCollection = (message) -> message.get('_id') is _messageId
  tags = messageData.get('tags')
  inTeam = _teamId is store.getIn(['device', '_teamId'])

  maybeUpdate = (messages) ->
    if messages? and messages.some(inCollection)
      messages.map (message) ->
        if inCollection(message)
          message.merge messageData
        else message
    else messages

  store
  .update 'messages', (cursor) ->
    if cursor.getIn([_teamId, _channelId])?
      cursor.updateIn [_teamId, _channelId], (messages) ->
        messages.map (message) ->
          if message.get('_id') is _messageId
            message.merge messageData
          else message
    else cursor
  .update 'taggedResults', (messages) ->
    if messages.some(inCollection)
      messages
      .map (message) ->
        if inCollection(message)
          message.merge messageData
        else message
      .filter (message) ->
        message.get('tags') and message.get('tags').size > 0
    else messages
  .update 'taggedMessages', (messages) ->
    if messages.some(inCollection)
      messages
      .map (message) ->
        if inCollection(message)
          message.merge messageData
        else message
      .filter (message) ->
        message.get('tags') and message.get('tags').size > 0
    else if tags?.size > 0 and inTeam
      messages.push messageData
    else messages
  .updateIn ['mentionedMessages', _teamId], maybeUpdate
  .updateIn ['postMessages', _teamId, _channelId], maybeUpdate
  .updateIn ['fileMessages', _teamId, _channelId], maybeUpdate
  .updateIn ['linkMessages', _teamId, _channelId], maybeUpdate
  .updateIn ['snippetMessages', _teamId, _channelId], maybeUpdate

# message object: http://talk.ci/doc/restful/message.create.html
# Notice! There is a fakeId
exports.correct = (store, messageData) ->
  _toId = messageData.get('_toId')
  _fakeId = messageData.get('fakeId')
  _roomId = messageData.get('_roomId')
  _teamId = messageData.get('_teamId')
  _userId = store.getIn ['user', '_id']
  _storyId = messageData.get('_storyId')
  _channelId = lookup.getMessageChannelId(messageData, _userId)
  _messageId = messageData.get('_id')
  inCollection = (message) -> message.get('_id') is _fakeId

  store
  .update 'messages', (cursor) ->
    if cursor.getIn([_teamId, _channelId])?
      cursor.updateIn [_teamId, _channelId], (messages) ->
        if messages.some(inCollection)
          messages.map (message) ->
            if inCollection(message)
              message.merge(messageData).delete('fakeId')
            else message
        else
          messages.push(messageData.delete('fakeId'))
    else cursor

exports.createLocal = (store, messageData) ->
  _teamId = messageData.get('_teamId')
  _roomId = messageData.get('_roomId')
  _toId = messageData.get('_toId')
  _userId = store.getIn ['user', '_id']
  _channelId = lookup.getMessageChannelId(messageData, _userId)

  store.update 'messages', (cursor) ->
    if cursor.getIn([_teamId, _channelId])?
      cursor.updateIn [_teamId, _channelId], (messages) ->
        messages.push messageData
    else cursor

exports.outdatedExcept = (store, data) ->
  _teamId = data.get('_teamId')
  _channelId = data.get('_channelId')

  path = ['messages', _teamId, _channelId]
  currentChannelData = store.getIn(path)

  store
  .delete 'messages'
  .setIn path, currentChannelData

exports.read = (store, messageData) ->
  _teamId = messageData.get('_teamId')
  _channelId = lookup.getMessageChannelId(messageData)
  data = messageData.get('data')

  if store.hasIn(['messages', _teamId])?
    store.setIn ['messages', _teamId, _channelId], data
  else
    store.setIn ['messages', _teamId], Immutable.Map().set(_channelId, data)

exports.receiptLoading = (store, messageData) ->
  _teamId = messageData.get('_teamId')
  _messageId = messageData.get('_id')
  _userId = store.getIn ['user', '_id']
  _channelId = lookup.getMessageChannelId(messageData, _userId)
  inCollection = (message) -> message.get('_id') is _messageId

  store
  .update 'messages', (cursor) ->
    if cursor.getIn([_teamId, _channelId])?
      cursor.updateIn [_teamId, _channelId], (messages) ->
        messages.map (message) ->
          if message.get('_id') is _messageId
            message.update 'receiptors', (receiptors) ->
              if receiptors and Immutable.List.isList(receiptors)
                receiptors.push(_userId)
              else
                Immutable.List([_userId])
          else message
    else cursor
