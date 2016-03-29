assign = require 'object-assign'

count = 0

emptyMessage =
  _id: undefined
  _toId: undefined
  _roomId: undefined
  _teamId: undefined
  _storyId: undefined
  attachments: []
  body: undefined # string
  createdAt: undefined # Date
  creator: undefined # object
  icon: 'normal'
  isSystem: false
  room: undefined # object
  tags: []
  team: '' # id
  to: undefined # object
  updatedAt: undefined # Date

module.exports = (fillData) ->
  count += 1
  fakeMessage = assign {}, emptyMessage, fillData
  now = (new Date).toISOString()
  fakeMessage.createdAt or= now
  fakeMessage.updatedAt or= now
  fakeMessage._id = "fake-#{now}-#{count}"
  fakeMessage
