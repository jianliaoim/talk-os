recorder = require 'actions-recorder'
Immutable = require 'immutable'

socket = require './socket'
actions = require '../actions/index'
handlers = require '../handlers'
dispatcher = require '../dispatcher'

if module.hot
  module.hot.accept '../handlers', ->
    handlers = require '../handlers'
  module.hot.accept '../actions', ->
    actions = require '../actions'

socket.on 'team:join', (data) ->
  dispatcher.handleServerAction {type: 'team/join', data}

socket.on 'team:leave', (data) ->
  handlers.teamLeave Immutable.fromJS(data)

socket.on 'team:update', (data) ->
  dispatcher.handleServerAction {type: 'team/update', data}

socket.on 'room:join', (data) ->
  dispatcher.handleServerAction {type: 'topic/invite', data}

socket.on 'room:leave', (data) ->
  handlers.topicLeave Immutable.fromJS(data)

socket.on 'room:create', (data) ->
  dispatcher.handleServerAction {type: 'topic/create', data}

socket.on 'room:update', (data) ->
  handlers.topicUpdate Immutable.fromJS(data)

socket.on 'room:archive', (data) ->
  handlers.topicArchive Immutable.fromJS(data)

socket.on 'room:remove', (data) ->
  handlers.topicRemove Immutable.fromJS(data)

socket.on 'room.prefs:update', (data) ->
  dispatcher.handleServerAction {type: 'topic-prefs/push', data}

socket.on 'message:create', (data) ->
  handlers.messageCreate Immutable.fromJS(data)

socket.on 'file:update', (data) ->
  dispatcher.handleServerAction {type: 'message/update', data}

socket.on 'message:update', (data) ->
  dispatcher.handleServerAction {type: 'message/update', data}

socket.on 'message:remove', (data) ->
  handlers.messageRemove Immutable.fromJS(data)

socket.on 'user:update', (data) ->
  dispatcher.handleServerAction {type: 'user/update', data}

socket.on 'integration:create', (data) ->
  dispatcher.handleServerAction {type: 'inte/create', data}

socket.on 'integration:update', (data) ->
  dispatcher.handleServerAction {type: 'inte/update', data}

socket.on 'integration:remove', (data) ->
  dispatcher.handleServerAction {type: 'inte/remove', data}

socket.on 'team.members.prefs:update', (data) ->
  dispatcher.handleServerAction {type: 'contact-prefs/push', data}

socket.on 'member:update', (data) ->
  dispatcher.handleServerAction {type: 'contact/update', data}

socket.on 'favorite:create', (data) ->
  dispatcher.handleServerAction {type: 'favorite/create', data}

socket.on 'favorite:remove', (data) ->
  dispatcher.handleServerAction {type: 'favorite/remove', data}

socket.on 'tag:create', (data) ->
  dispatcher.handleServerAction {type: 'tag/create', data}

socket.on 'tag:update', (data) ->
  dispatcher.handleServerAction {type: 'tag/update', data}

socket.on 'tag:remove', (data) ->
  dispatcher.handleServerAction {type: 'tag/remove', data}

socket.on 'invitation:create', (data) ->
  dispatcher.handleServerAction {type: 'team/join', data}

socket.on 'invitation:remove', (data) ->
  dispatcher.handleServerAction {type: 'team/leave', data}

socket.on 'story:create', (data) ->
  dispatcher.handleServerAction {type: 'story/create', data}

socket.on 'story:leave', (data) ->
  dispatcher.handleServerAction {type: 'story/leave', data}

socket.on 'story:join', (data) ->
  dispatcher.handleServerAction {type: 'story/join', data}

socket.on 'story:remove', (data) ->
  dispatcher.handleServerAction {type: 'story/remove', data}

socket.on 'story:update', (data) ->
  dispatcher.handleServerAction {type: 'story/update', data}

socket.on 'notification:update', (data) ->
  handlers.notificationUpdate Immutable.fromJS(data)

socket.on 'notification:remove', (data) ->
  handlers.notificationRemove Immutable.fromJS(data)

socket.on 'group:create', (data) ->
  dispatcher.handleServerAction {type: 'group/create', data}

socket.on 'group:remove', (data) ->
  dispatcher.handleServerAction {type: 'group/remove', data}

socket.on 'group:update', (data) ->
  dispatcher.handleServerAction {type: 'group/update', data}

socket.on 'activity:create', (data) ->
  handlers.activities.create data

socket.on 'activity:update', (data) ->
  handlers.activities.update data

socket.on 'activity:remove', (data) ->
  handlers.activities.remove data

module.exports = socket
