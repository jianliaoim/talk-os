assign = require 'object-assign'

notifyActions = require './notify'
deviceActions = require './device'

dispatcher = require '../dispatcher'

api = require '../network/api'

###
 * reference: http://talk.ci/doc/restful/notification.create.html
 *
 * API which create a empty notification,
 * once you open the channel not in notifications,
 * you will get one in the left sidebar.
 *
 * @param {string} _teamId
 * @param {string} _targetId
 * @param {string} type [ 'dms', 'room', 'story' ]
 * @param {function} success
 * @param {function} fail
 *
 * @return null
###

exports.create = (_teamId, _targetId, type, success, fail) ->
  config =
    data:
      _teamId: _teamId
      _targetId: _targetId
      type: type

  api.notifications.create.post config
  .then (resp) ->
    dispatcher.handleViewAction
      type: 'notification/create'
      data: resp
    success?()
  .catch (error) ->
    fail?()

  return null

# http://talk.ci/doc/restful/notification.read.html
exports.read = (_teamId, { maxUpdatedAt, limit }, success, fail) ->
  config =
    queryParams: assign {},
      { _teamId }
      { maxUpdatedAt: new Date(maxUpdatedAt).valueOf() } if maxUpdatedAt?
      { limit } if limit?

  api.notifications.read.get config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'notification/read'
        data: { _teamId, data: resp }
      success? resp

# http://talk.ci/doc/restful/notification.update.html
# data:
#   isPinned: Bool
#   isMute: Bool
#   unreadNum: Integer
#   _latestReadMessageId: String
exports.update = (_notyId, data, success, fail) ->
  config =
    pathParams:
      id: _notyId
    data: assign {}, data

  api.notifications.update.put config
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'notification/update'
        data: resp
      success? resp

###
 * This method is built for update some property
 * of notification locally.
 *
 * @param {string} _notyId
 * @param {object} data
 *
 * @return null
###

exports.clearUnread = (noty) ->
  config =
    pathParams:
      id: noty.get('_id')
    data:
      _latestReadMessageId: noty.get '_emitterId' # _emitterId === _messageId
      unreadNum: 0

  _teamId = noty.get('_teamId')
  _channelId = noty.get('_targetId')

  deviceActions.clearingUnread(_teamId, _channelId, true)

  dispatcher.handleViewAction
    type: 'notification/pre-clear-team-unread'
    data: noty

  api.notifications.update.put(config)
    .then (resp) ->
      deviceActions.clearingUnread(_teamId, _channelId, false)
      dispatcher.handleViewAction
        type: 'notification/post-clear-team-unread'
        data: resp
      dispatcher.handleViewAction
        type: 'notification/update'
        data: resp
    .catch ->
      deviceActions.clearingUnread(_teamId, _channelId, false)
