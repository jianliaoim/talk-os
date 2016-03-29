Promise = require 'bluebird'
Err = require 'err1st'
_ = require 'lodash'
serviceLoader = require 'talk-services'
limbo = require 'limbo'
logger = require 'graceful-logger'

app = require '../server'

$service = serviceLoader.load 'talkai'

{
  MessageModel
  PreferenceModel
} = limbo.use 'talk'

# Register hook after create message
app.controller 'message', ->

  @after 'sendMsgToTalkai', only: 'create', parallel: true

  @action 'sendMsgToTalkai', (req, res, message) ->

    $service.then (service) ->
      return unless message._toId and "#{message._toId}" is "#{service.robot._id}"

      $preference = PreferenceModel.findOneAsync _id: message._creatorId
      .then (preference) ->
        if preference?.customOptions?.hasGetReply is false
          preference.$save()
        else preference

      $replyMessage = $preference.then (preference) ->
        req.message = message
        if preference?.customOptions?.needTalkAIReply
          service.receiveEvent 'message.create', req

      $replyMessage = $replyMessage.then (replyMessage) ->
        return replyMessage unless toString.call(replyMessage) is '[object Object]' and not _.isEmpty(replyMessage)
        replyMessage = new MessageModel replyMessage
        replyMessage.to = message._creatorId
        replyMessage.team = message._teamId
        replyMessage.creator = service.robot._id
        replyMessage.$save()

    .catch (err) -> logger.warn err.stack
