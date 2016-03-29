limbo = require '../lib/components/limbo'
pinyin = require 'pinyin'
util = require '../lib/util'
talk = limbo.use 'talk'
Promise = require 'bluebird'
{UserModel, RoomModel} = talk

exports.up = (next) ->

  _saveUsers = (callback) ->
    users = UserModel.find().stream()
    users
    .on 'data', (user) ->
      return if user.pinyin and user.pinyins
      user.pinyin = pinyin(user.name, style: pinyin.STYLE_NORMAL).join('')
      user.pinyins = util.arrHorizon pinyin(user.name, heteronym: true, style: pinyin.STYLE_NORMAL)
      user.save()
    .on 'error', callback
    .on 'close', callback

  _saveRooms = (callback) ->
    rooms = RoomModel.find().stream()
    rooms
    .on 'data', (room) ->
      return if room.pinyin and room.pinyins
      room.pinyin = pinyin(room.topic, style: pinyin.STYLE_NORMAL).join('')
      room.pinyins = util.arrHorizon pinyin(room.topic, heteronym: true, style: pinyin.STYLE_NORMAL)
      room.save()
    .on 'error', callback
    .on 'close', callback

  Promise.all [
    Promise.promisify(_saveUsers)()
    Promise.promisify(_saveRooms)()
  ]
  .then -> next()
  .catch next

exports.down = (next) ->
  mongo ->
    db.users.update({}, {$unset: {pinyin: "", pinyins: ""}}, {multi: true})
    db.rooms.update({}, {$unset: {pinyin: "", pinyins: ""}}, {multi: true})
  next()
