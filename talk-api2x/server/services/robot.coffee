Promise = require 'bluebird'
Err = require 'err1st'
_ = require 'lodash'
serviceLoader = require 'talk-services'
limbo = require 'limbo'
logger = require 'graceful-logger'

app = require '../server'
{socket} = require '../components'

{
  UserModel
  TeamModel
  MessageModel
  IntegrationModel
  NotificationModel
} = limbo.use 'talk'

$service = serviceLoader.load 'robot'

_postMessage = ({message, integration}) ->
  service = this
  return unless integration.url

  msg = message.toJSON()
  msg.event = 'message.create'
  msg.token = integration.token if integration.token

  service.httpPost integration.url, msg, retryTimes: 3

  .then (body = {}) ->
    return unless body.text or body.content or body.body
    replyMessage = new MessageModel
      body: body.content or body.body
      authorName: body.authorName
      creator: integration._robotId
      displayType: body.displayType
    if body.text
      attachment =
        category: 'quote'
        color: body.color
        data: body
      replyMessage.attachments = [attachment]
    # Append default fields
    switch
      when message.room
        replyMessage.room = message.room
      when message.story
        replyMessage.story = message.story
      when message.to
        replyMessage.to = message.creator
      else throw new Err 'FIELD_MISSING', 'room story to'
    replyMessage.team = message.team
    replyMessage.$save()

  .then (message) ->
    # Reset errorTimes
    return message unless integration.errorTimes > 0
    integration.errorTimes = 0
    integration.lastErrorInfo = undefined
    integration.errorInfo = undefined
    integration.$save().then -> message

  .catch (err) ->
    integration.errorTimes += 1
    integration.lastErrorInfo = err.message
    integration.errorInfo = err.message if integration.errorTimes > 5
    integration.$save()

_receiveWebhook = (req, res) ->
  return unless req.integration?._robotId

  req.set '_sessionUserId', "#{req.integration._robotId}"
  req.set '_teamId', "#{req.integration._teamId}", true

  msgController = app.controller 'message'

  $permission = Promise.promisify(msgController.call).call msgController, 'accessibleMessage', req, res

  $message = Promise.all [$permission]

  .spread ->

    payload = _.assign {}
      , req.query or {}
      , req.body or {}
    {content, authorName, title, text, redirectUrl, imageUrl} = payload

    message =
      body: content or payload.body
      authorName: authorName
      creator: req.integration._robotId
      team: req.integration._teamId

    switch
      when payload._roomId
        message.room = payload._roomId
      when payload._toId
        message.to = payload._toId
      when payload._storyId
        message.story = payload._storyId
      else throw new Err('PARAMS_MISSING', '_toId _roomId _storyId')

    if title or text or redirectUrl or imageUrl
      message.attachments = [
        category: 'quote'
        color: payload.color
        data:
          title: title
          text: text
          redirectUrl: redirectUrl
          imageUrl: imageUrl
      ]

    message

###*
 * Create a new robot and invite him to this team
 * Fork current robot as the bundle user of this integration
 * @param  {Request} req with integration
 * @return {Promise}
###
_createRobot = ({integration}) ->
  service = this

  robot = new UserModel
    name: integration.title
    avatarUrl: integration.iconUrl
    description: integration.description
    isRobot: true

  $robot = robot.$save()

  $team = TeamModel.findOneAsync _id: integration._teamId
  .then (team) ->
    throw new Err('OBJECT_MISSING', "Team #{integration._teamId}") unless team
    team

  $addMember = Promise.all [$robot, $team]
  .spread (robot, team) ->
    integration.robot = robot
    team.addMemberAsync robot

  $broadcast = Promise.all [$robot, $team, $addMember]
  .spread (robot, team) ->
    robot.team = team
    robot._teamId = team._id
    socket.broadcast "team:#{team._id}", "team:join", robot

###*
 * Update robot's infomation
 * @param  {Request} req with integration
 * @return {Promise} robot
###
_updateRobot = (req) ->
  {integration} = req
  return unless integration._robotId
  $robot = UserModel.findOneAsync _id: integration._robotId
  .then (robot) ->
    return unless robot
    robot.name = req.get 'title' if req.get 'title'
    robot.avatarUrl = req.get 'iconUrl' if req.get 'iconUrl'
    robot.description = req.get 'description' if req.get 'description'
    robot.updatedAt = new Date
    robot.$save()

###*
 * Remove this robot from team
 * @param  {Request} req with integration
 * @return {Promise}
###
_removeRobot = ({integration}) ->

  return unless integration._robotId

  $removeRobots = TeamModel.removeMemberAsync integration._teamId, integration._robotId
  .then ->
    data =
      _teamId: integration._teamId
      _userId: integration._robotId
    socket.broadcast "team:#{integration._teamId}", "team:leave", data

  $removeNotifications = NotificationModel.removeByOptionsAsync target: integration._robotId, team: integration._teamId

  Promise.all [$removeRobots, $removeNotifications]

$service.then (service) ->

  service.registerEvent 'message.create', _postMessage

  service.registerEvent 'service.webhook', _receiveWebhook

  service.registerEvent 'before.integration.create', _createRobot

  service.registerEvent 'before.integration.update', _updateRobot

  service.registerEvent 'before.integration.remove', _removeRobot

# Register hook after create message
app.controller 'message', ->

  @after 'sendMsgToRobot', only: 'create', parallel: true

  @action 'sendMsgToRobot', (req, res, message) ->
    # Send dms to robot
    if message.to?.isRobot
      $integrations = IntegrationModel.findOneAsync
        team: message._teamId
        robot: message.to._id
        errorInfo: null
      .then (integration) -> if integration then [integration] else []

    # Check mentions in channel
    else if (message.room or message.story) and message.mentions?.length
      $integrations = UserModel.findAsync
        _id: $in: message.mentions
        isRobot: true
      , '_id'
      .then (robots = []) ->
        _robotIds = robots.map (robot) -> "#{robot._id}"
        return [] unless _robotIds?.length
        IntegrationModel.findAsync
          team: message._teamId
          robot: $in: _robotIds
          errorInfo: null
    # Do nothing
    else return

    Promise.all [$service, $integrations]

    .spread (service, integrations) ->

      return unless service and integrations?.length

      Promise.map integrations, (integration) ->
        _req = _.clone req
        _req.integration = integration
        _req.message = message
        service.receiveEvent 'message.create', _req

    .catch (err) -> logger.warn err.stack

# Register hook after remove team member
app.controller 'team', ->

  @after 'removeRobotIntegration', only: 'removeMember', parallel: true

  @action 'removeRobotIntegration', (req, res, result) ->
    {_userId} = req.get()

    return unless _userId

    $integration = IntegrationModel.findOneAsync robot: _userId

    .then (integration) ->
      return unless integration
      integration.$remove().then (integration) ->
        _integration = _.omit(integration.toJSON(), 'token', 'refreshToken')
        res.broadcast "team:#{integration._teamId}", "integration:remove", _integration

    .catch (err) -> logger.warn err.stack

