# Sweep out guest and send messages to their email boxes
Promise = require 'bluebird'
{socket, limbo} = require '../components'
{gmMailer} = require '../mailers'

{
  MemberModel
  RoomModel
  MessageModel
} = limbo.use 'talk'

module.exports = (_userId) ->

  MemberModel.find
    user: _userId
    room: $ne: null
    isQuit: false
  .populate 'room'
  .execAsync()
  .map (member) ->

    return unless member.room

    member.room.removeMemberAsync _userId

    .then (room) ->
      data = _roomId: room._id, _userId: _userId
      socket.broadcast "team:#{room._teamId}", "room:leave", data
      member.room.createLeaveMessage _userId
      gmMailer.send _userId, room._id
