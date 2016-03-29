Promise = require 'bluebird'
Err = require 'err1st'
limbo = require 'limbo'
logger = require 'graceful-logger'
serviceLoader = require 'talk-services'

{
  MessageModel
} = limbo.use 'talk'

$talkai = serviceLoader.load('talkai').then (service) -> service.robot

module.exports = (_messageId) ->

  $message = MessageModel.findOneAsync _id: _messageId

  .then (message) ->
    throw new Err('OBJECT_MISSING', "Message #{_messageId}") unless message
    message

  # Create new message
  Promise.all [$message, $talkai]

  .spread (message, talkai) ->

    throw new Err('OBJECT_MISSING', "Talkai") unless talkai?._id

    msgBody = "{{__info-discussion-started}} #{message.body}"

    msgBody = "<$at|all|@所有成员$> #{msgBody}"

    remindMsg = new MessageModel
      creator: talkai._id
      team: message._teamId
      body: msgBody

    switch
      when message._storyId then remindMsg.story = message._storyId
      when message._roomId then remindMsg.room = message._roomId
      else throw new Err('PARAMS_INVALID', "Message type")

    remindMsg.$save()
