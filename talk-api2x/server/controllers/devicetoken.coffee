_ = require 'lodash'
limbo = require 'limbo'
Promise = require 'bluebird'
app = require '../server'
{DeviceTokenModel} = limbo.use 'talk'

module.exports = deviceTokenController = app.controller 'devicetoken', ->

  @ensure 'token clientType clientId', only: 'create'

  @action 'create', (req, res, callback) ->
    {_sessionUserId, clientId, token, clientType} = req.get()

    update = token: token

    conditions =
      type: clientType
      $or: [
        user: _sessionUserId
        clientId: clientId
      ,
        token: token
      ]

    $devicetokens = DeviceTokenModel.find conditions

    .sort updatedAt: -1

    .execAsync()

    .then (devicetokens) ->
      if devicetokens?.length is 0
        devicetoken = new DeviceTokenModel
      else if devicetokens?.length is 1
        devicetoken = devicetokens[0]
      else
        devicetoken = devicetokens[0]
        _removeIds = devicetokens[1..].map (devicetoken) -> "#{devicetoken._id}"
        $removeDeviceTokens = DeviceTokenModel.removeAsync
          _id: $in: _removeIds

      devicetoken.user = _sessionUserId
      devicetoken.token = token
      devicetoken.type = clientType
      devicetoken.clientId = clientId
      devicetoken.updatedAt = new Date

      Promise.all [devicetoken.$save(), $removeDeviceTokens]
      .spread (devicetoken) -> devicetoken

    .nodeify callback
