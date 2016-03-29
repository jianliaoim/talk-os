async = require 'async'
limbo = require 'limbo'
Err = require 'err1st'

util = require '../../util'
app = require '../../server'

{
  MessageModel
  RoomModel
  MemberModel
} = limbo.use 'talk'

module.exports = messageController = app.controller 'guest/message', ->

  @ensure '_roomId', only: 'read'

  ###*
   * Read messages from guest room
   * This api should guarantee the `_roomId` param
  ###
  @action 'read', (req, res, callback) ->
    {_roomId, _sessionUserId} = req.get()

    async.waterfall [

      (next) ->
        MemberModel.findOne
          room: _roomId
          user: _sessionUserId
          isQuit: false
        .populate 'room'
        .exec next

      (member, next) ->
        return next(new Err('MEMBER_CHECK_FAIL', 'room')) unless member?.room
        return next(new Err('ROOM_IS_ARCHIVED')) if member.room.isArchived
        return next(new Err('GUEST_MODE_DISABLED')) unless member.room.guestToken
        options = req.get()
        options._id = $gt: util.getIdByDate(member.createdAt) unless member.room.isGuestVisible
        MessageModel.findMessagesFromRoom _roomId, options, callback

    ], callback
