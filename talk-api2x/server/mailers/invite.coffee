async = require 'async'
request = require 'request'
BaseMailer = require './base'
util = require '../util'
config = require 'config'
{logger, limbo} = require '../components'

{
  UserModel
  RoomModel
  TeamModel
} = limbo.use 'talk'

class InviteMailer extends BaseMailer

  delay: 0
  action: 'send'
  template: 'invite'

  send: (_senderId, invitee) ->
    label = if invitee._roomId? then '话题' else '团队'

    return unless invitee?.email

    self = this
    email =
      id: "invite" + Math.random() + new Date().getTime()
      to: invitee.email
      label: label
      titleName: '话题'

    async.auto
      findSender: (callback) ->
        UserModel.findOne
          _id: _senderId
        , (err, user) ->
          email.sender = user
          callback err
      findRoom: (callback) ->
        return callback() unless invitee._roomId
        RoomModel.findOne
          _id: invitee._roomId
        , (err, room) ->
          if room?.isGeneral
            email.titleName = '公告板'
          else
            email.titleName = room?.topic
          callback err
      findTeam: (callback) ->
        return callback() unless invitee._teamId
        TeamModel.findOne
          _id: invitee._teamId
        , (err, team) ->
          email.titleName = team?.name unless invitee._roomId
          invitee.team = team
          callback err
      setRedirectUrl: ['findTeam', (callback) ->
        if invitee.isInvite
          email.redirectUrl = invitee.team.inviteUrl
        else
          email.redirectUrl = util.buildTeamUrl invitee._teamId, invitee._roomId
        callback()
      ]
    , (err) ->
      logger.warn err.stack if err
      return unless email.sender and not err
      email.subject = "[简聊] #{email.sender.name}邀请你加入#{label}#{email.titleName}"
      self._sendByRender email

module.exports = new InviteMailer
