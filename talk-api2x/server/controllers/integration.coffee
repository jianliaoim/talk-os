Err = require 'err1st'
_ = require 'lodash'
async = require 'async'
limbo = require 'limbo'
Promise = require 'bluebird'

serviceLoader = require 'talk-services'
util = require '../util'
{i18n, logger} = require '../components'
app = require '../server'

{
  IntegrationModel
  MessageModel
  RoomModel
  PreferenceModel
} = limbo.use 'talk'

module.exports = integrationController = app.controller 'integration', ->

  @mixin require './mixins/permission'

  @ensure 'appToken', only: 'batchRead error'
  @ensure '_teamId category', only: 'create'
  @ensure '_teamId', only: 'read'

  @before 'readableIntegration', only: 'readOne'
  @before 'editableIntegration', only: 'update remove'
  @before 'accessibleIntegration', only: 'read create'
  @before 'rejectOfficialRooms', only: 'create'

  @after 'afterError', only: 'error', parallel: true

  editableFields = [
    'token'
    'notifications'
    'showname'
    'repos'
    'title'
    'description'
    '_roomId'
    'iconUrl'
    'events'
    'project'
    'url'
    'group'
  ]

  @action 'read', (req, res, callback) ->
    {_teamId, _sessionUserId} = req.get()
    async.waterfall [

      (next) -> IntegrationModel.find team: _teamId, next

      (integrations, next) ->

        _integrations = []
        _privateRoomIds = []

        _roomIds = _.uniq(integrations.map (integration) -> integration._roomId)
        # Remove the integrations in private rooms
        async.waterfall [

          (next) ->
            RoomModel.find
              _id: $in: _roomIds
              isPrivate: true
            , next

          (rooms, next) ->
            return next(null, integrations) unless rooms?.length
            _privateRoomIds = rooms.map (room) -> "#{room._id}"
            RoomModel.filterPrivateRooms rooms, _sessionUserId, next

          (rooms, next) ->
            _joinedPrivateRoomIds = rooms.map (room) -> "#{room._id}"
            _integrations = integrations.filter (integration) ->
              _roomId = "#{integration._roomId}"
              _roomId not in _privateRoomIds or _roomId in _joinedPrivateRoomIds
            next null, _integrations

        ], next

      (integrations, next) ->
        integrations = integrations.map (integration) -> _.omit(integration.toJSON(), 'token', 'refreshToken')
        next null, integrations

    ], callback

  @action 'readOne', (req, res, callback) ->
    {_id, integration, _sessionUserId} = req.get()
    unless "#{integration._creatorId}" is _sessionUserId
      integration = _.omit(integration.toJSON(), 'token', 'refreshToken')
    callback null, integration

  @action 'create', (req, res, callback) ->
    {_teamId, _roomId, _sessionUserId, category} = req.get()
    integration = _.assign req.get(), _creatorId: _sessionUserId

    $service = serviceLoader.load category

    # Before create
    $integration = $service.then (service) ->

      req.integration = integration = new IntegrationModel integration

      integration.iconUrl or= service.iconUrl
      integration.title or= service.title
      integration.group or= service.group

      service.receiveEvent 'before.integration.create', req

      .then -> integration.$save()

    # After create
    Promise.all [$service, $integration]

    .spread (service, integration) ->
      # Send the complete integration model to services
      service.receiveEvent 'integration.create', req
      .catch (err) -> logger.warn err.stack

      _integration = _.omit(integration.toJSON(), 'token', 'refreshToken')

      res.broadcast "team:#{_teamId}", 'integration:create', _integration

      if integration._roomId
        message = new MessageModel
          _creatorId: _sessionUserId
          _roomId: _roomId
          _teamId: _teamId
          body: "{{__info-create-integration}} #{integration.title}"
          isSystem: true
          icon: 'create-integration'
        message.save()

      integration

    .nodeify callback

  @action 'update', (req, res, callback) ->
    {_id, _sessionUserId, integration} = req.get()
    update = _.pick req.get(), editableFields
    return callback(new Err('PARAMS_MISSING', editableFields.join(', '))) if _.isEmpty(update)

    $service = serviceLoader.load integration.category

    # Before update
    $integration = $service.then (service) ->
      req.integration = integration
      service.receiveEvent 'before.integration.update', req

    .then ->
      integration[key] = value for key, value of update
      integration.errorInfo = null
      integration.errorTimes = 0
      integration.$save()

    # After update
    Promise.all [$service, $integration]

    .spread (service, integration) ->
      service.receiveEvent 'integration.update', req
      .catch (err) -> logger.warn err.stack

      _integration = _.omit(integration.toJSON(), 'token', 'refreshToken')
      res.broadcast "team:#{integration._teamId}", "integration:update", _integration

      if integration._roomId
        message = new MessageModel
          _creatorId: _sessionUserId
          _roomId: integration._roomId
          _teamId: integration._teamId
          body: "{{__info-update-integration}} #{integration.title}"
          isSystem: true
          icon: 'update-integration'
        message.save()

      integration

    .nodeify callback

  @action 'remove', (req, res, callback) ->
    {_id, _sessionUserId, integration} = req.get()

    $service = serviceLoader.load integration.category

    # Before remove
    $integration = $service.then (service) ->

      req.integration = integration

      service.receiveEvent 'before.integration.remove', req

      .then -> integration.$remove()

    # After remove
    Promise.all [$service, $integration]

    .spread (service, integration) ->

      service.receiveEvent 'integration.remove', req
      .catch (err) -> logger.warn err.stack

      _integration = _.omit(integration.toJSON(), 'token', 'refreshToken')
      res.broadcast "team:#{integration._teamId}", "integration:remove", _integration

      if integration._roomId
        message = new MessageModel
          _creatorId: _sessionUserId
          _roomId: integration._roomId
          _teamId: integration._teamId
          body: "{{__info-remove-integration}} #{integration.title or service.title}"
          isSystem: true
          icon: 'remove-integration'
        message.save()

      integration

    .nodeify callback

  @action 'batchRead', (req, res, callback) ->
    {appToken} = req.get()

    $service = serviceLoader.getServiceByToken appToken

    $service.then (service) ->
      IntegrationModel.findAsync
        $or: [
          category: service.name
        ,
          group: service.name
        ]
        errorInfo: null

    .nodeify callback

  # Set the error infomation of integration
  # This api is only opened to integration robots
  @action 'error', (req, res, callback) ->
    {_id, errorInfo, appToken} = req.get()

    $service = serviceLoader.getServiceByToken appToken

    $integration = IntegrationModel.findOne(_id: _id).populate('room').execAsync()

    Promise.all [$service, $integration]

    .spread (service, integration) ->
      unless integration?.category and integration.category is service.name
        throw new Err 'NO_PERMISSION'
      integration.errorInfo = errorInfo
      integration.updatedAt = new Date
      integration.$save()

    .nodeify callback

  @action 'afterError', (req, res, integration) ->
    # Send messages to user
    _integration = _.omit(integration.toJSON(), 'token', 'refreshToken')
    res.broadcast "team:#{integration._teamId}", "integration:update", _integration

    {room} = integration
    _toIds = ["#{integration._creatorId}"]  # The creator of integration
    _toIds.push ["#{room._creatorId}"] unless "#{room?._creatorId}" in _toIds

    $talkai = serviceLoader.getRobotOf 'talkai'

    Promise.map _toIds, (_toId) ->
      $content = PreferenceModel.findOneAsync _id: _toId
      .then (preference) ->
        language = preference?.language or 'zh'
        i18n.fns(language).inteErrorMessage integration, room.topic

      Promise.all [$content, $talkai]
      .spread (content, talkai) ->
        message = new MessageModel
          creator: talkai._id
          team: integration._teamId
          to: _toId
          body: content
        message.$save()
    .catch (err) -> logger.warn err.stack

  @action 'checkRSS', (req, res, callback) ->
    $service = serviceLoader.load 'rss'

    $service.then (service) ->
      service.receiveApi 'checkRSS', req, res
    .nodeify callback

  @action 'rejectOfficialRooms', (req, res, callback) ->
    # User can not add integrations in official teams
    {_roomId, member} = req.get()
    if "#{_roomId}" in ['544f9896480ab1825e6a1fc5'] and member.role not in ['owner', 'admin']
      return callback(new Err('CAN_NOT_ADD_INTEGRATION_IN_OFFICIAL_ROOMS'))
    callback()
