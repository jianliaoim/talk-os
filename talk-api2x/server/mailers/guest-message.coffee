moment = require 'moment'
async = require 'async'
limbo = require 'limbo'
Err = require 'err1st'
i18n = require 'i18n'

BaseMailer = require './base'
util = require '../util'

db = limbo.use 'talk'
{
  UserModel
  MessageModel
  MemberModel
} = db

class GuestMessageMailer extends BaseMailer

  template: 'guest-message'

  send: (_userId, _roomId) ->
    email = id: "guestmessage:#{_userId}:#{_roomId}"

    async.auto

      findUser: (callback) ->
        UserModel.findOne _id: _userId, (err, user) ->
          return callback(new Err("FIELD_MISSING", "email")) unless user?.email
          email.user = user
          email.to = user.email
          callback()

      findMember: ['findUser', (callback) ->
        MemberModel.findOne
          user: _userId
          room: _roomId
          isQuit: true
        , (err, member) ->
          return callback(new Err("OBJECT_MISSING", 'member')) unless member
          email.member = member
          callback()
      ]

      findMessages: ['findMember', (callback) ->
        {member} = email
        options =
          limit: 100
          sort: _id: 1
          _id:
            $gte: util.getIdByDate member.joinAt or member.createdAt
            $lt: util.getIdByDate (member.quitAt or member.updatedAt), 'ffffffffffffffff'
          isSystem: false
        MessageModel.findMessagesFromRoom _roomId, options, (err, messages) ->
          email.messages = messages
          email.room = messages?[0]?.room
          email.clickUrl = util.buildGuestUrl email.room.guestToken if email.room?.guestToken
          callback()
      ]

      sendMail: ['findMessages', (callback) ->
        {messages, room} = email
        return callback(new Err('EMPTY_MESSAGE')) unless messages?.length and room
        messages = messages.map (message) ->
          message.alert = i18n.replace message.getAlert()
          message.formatedDate = moment(new Date(message.createdAt)).format('HH:mm')
          message
        email.messages = messages
        email.subject = """[简聊] 话题 “#{room.topic}” 中的聊天记录"""
        email.loginUrl = util.buildAccountPageUrl()
        callback()
      ]

    , (err) => @_sendByRender email unless err

module.exports = new GuestMessageMailer
