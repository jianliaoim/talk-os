
exports.team = team = require './team'
exports.file = file = require './file'
exports.topic = topic = require './topic'
exports.router = router = require './router'
exports.unread = unread = require './unread'
exports.account = account = require './account'
exports.message = message = require './message'
exports.network = network = require './network'
exports.activities = activities = require './activities'
exports.initialize = initialize = require './initialize'
exports.notification = notification = require './notification'
exports.collection = collection = require './collection'

# deprecated syntax, use `handlers.team.leave` instead!
exports.teamLeave = team.leave

exports.topicLeave = topic.leave
exports.topicUpdate = topic.update
exports.topicRemove = topic.remove
exports.topicArchive = topic.archive

exports.routerRoom = router.room
exports.routerChat = router.chat
exports.routerTeam = router.team
exports.routerBack = router.back
exports.routerHome = router.home
exports.routerUnreadTeam = router.unreadTeam

exports.messageRemove = message.remove
exports.messageCreate = message.create

exports.notificationUpdate = notification.update
exports.notificationRemove = notification.remove

exports.accountBind = account.bind
exports.accountRedirectBindEmail = account.redirectBindEmail
exports.accountRedirectChangeEmail = account.redirectChangeEmail
exports.accountUnbindEmail = account.unboundEmail

exports.fileCreate = file.create
exports.fileProgress = file.progress
exports.fileSuccess = file.success
exports.fileError = file.error
exports.fileAbort = file.abort
