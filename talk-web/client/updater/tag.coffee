
Immutable = require 'immutable'

# dataSchema =
#   _teamId: {type: 'string'}
#   tags:
#     type: 'array'
#     items: {} # complicated
exports.read = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  tagsList = actionData.get('tags')

  store.setIn ['tags', _teamId], tagsList

exports.create = (store, tagData) ->
  _teamId = tagData.get('_teamId')

  store.update 'tags', (cursor) ->
    if cursor.get(_teamId)?
      cursor.update _teamId, (tags) ->
        tags.push tagData
    else
      cursor.set _teamId, Immutable.List([tagData])

# http://talk.ci/doc/event/tag.update.html
exports.update = (store, tagData) ->
  _teamId = tagData.get('_teamId')
  _tagId = tagData.get('_id')
  inCollection = (tag) -> tag.get('_id') is _tagId

  updateInMessages = (messages) ->
    messages.map (message) ->
      tags = message.get('tags')
      if tags? and tags.some(inCollection)
        message.update 'tags', (tags) ->
          tags.map (tag) ->
            if tag.get('_id') is _tagId
              tag.merge tagData
            else tag
      else message

  store
  .update 'tags', (cursor) ->
    cursor.update _teamId, (tags) ->
      tags.map (tag) ->
        if tag.get('_id') is _tagId
          tag.merge tagData
        else tag
  .update 'messages', (cursor) ->
    if cursor.has(_teamId)
      cursor.update _teamId, (rooms) ->
        rooms.map updateInMessages
    else cursor
  .update 'taggedMessages', updateInMessages
  .update 'taggedResults', updateInMessages

exports.remove = (store, tagData) ->
  _teamId = tagData.get('_teamId')
  _tagId = tagData.get('_id')
  inCollection = (tag) -> tag.get('_id') is _tagId

  removeInMessages = (messages) ->
    messages.map (message) ->
      tags = message.get('tags')
      if tags? and tags.some(inCollection)
        message.update 'tags', (tags) ->
          tags.filterNot inCollection
      else message

  filterMessages = (messages) ->
    removeInMessages(messages).filter (message) ->
      message.get('tags').size > 0

  store
  .update 'tags', (cursor) ->
    cursor.update _teamId, (tags) ->
      tags.filterNot inCollection
  .update 'messages', (cursor) ->
    if cursor.has(_teamId)
      cursor.update _teamId, (rooms) ->
        rooms.map removeInMessages
    else cursor
  .update 'taggedMessages', filterMessages
  .update 'taggedResults', filterMessages
