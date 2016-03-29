
Immutable = require 'immutable'

tag = require './tag'
user = require './user'
misc = require './misc'
team = require './team'
inte = require './inte'
file = require './file'
topic = require './topic'
draft = require './draft'
guest = require './guest'
group = require './group'
prefs = require './prefs'
story = require './story'
unread = require './unread'
notify = require './notify'
router = require './router'
device = require './device'
account = require './account'
contact = require './contact'
message = require './message'
favorite = require './favorite'
settings = require './settings'
favResult = require './fav-result'
activities = require './activities'
collection = require './collection'
topicPrefs = require './topic-prefs'
contactPrefs = require './contact-prefs'
notification = require './notification'
notifyBanner = require './notify-banner'
searchMessage = require './search-message'
taggedMessage = require './tagged-message'
taggedResults = require './tagged-results'
mentionedMessages = require './mentioned-message'

methods = {
  'tag/read': tag.read
  'tag/create': tag.create
  'tag/update': tag.update
  'tag/remove': tag.remove

  'misc/outdate-store': misc.outdateStore

  'user/me': user.me
  'user/update': user.update

  'team/join': team.join
  'team/fetch': team.fetch
  'team/leave': team.leave

  'team/create': team.create
  'team/update': team.update
  'team/remove-invite': team.removeInvite
  'team/thirds': team.getThirds
  'team/sync-one': team.syncOne
  'team/topics': team.teamTopics
  'team/members': team.teamMembers
  'team/invitations': team.teamInvitations

  'inte/fetch': inte.fetch
  'inte/create': inte.create
  'inte/remove': inte.remove
  'inte/update': inte.update
  'inte/settings': inte.settings

  'topic/join': topic.join
  'topic/fetch': topic.fetch
  'topic/leave': topic.leave
  'topic/invite': topic.invite
  'topic/update': topic.update
  'topic/create': topic.create
  'topic/remove': topic.remove
  'topic/archive': topic.archive
  'topic/remove-member': topic.removeMember
  'topic/reset-archived': topic.resetArchived

  'draft/post-save': draft.postSave
  'draft/draft-save': draft.draftSave
  'draft/post-delete': draft.postDelete
  'draft/draft-delete': draft.draftDelete
  'draft/snippet-save': draft.snippetSave
  'draft/snippet-delete': draft.snippetDelete
  'draft/toggle-markdown': draft.toggleMarkdown

  'guest-topic/reset': guest.reset
  'guest-topic/fetch': guest.fetch
  'guest-topic/clear': guest.clear

  'prefs/update': prefs.update

  'unread/check': unread.check

  'notify/create': notify.create
  'notify/remove': notify.remove

  'router/go': router.go

  'device/tuned': device.tuned
  'device/reload': device.reload
  'device/loaded': device.loaded
  'device/loading': device.loading
  'device/mark-team': device.markTeam
  'device/disconnect': device.disconnect
  'device/detect-focus': device.detectFocus
  'device/view-attachment': device.viewAttachment
  'device/set-edit-message-id': device.setEditMessageId

  'account/fetch': account.fetch
  'account/bind': account.bind
  'account/unbind': account.unbind
  'account/unbind-email': account.unbindEmail

  'contact/read': contact.read
  'contact/fetch': contact.fetch
  'contact/remove': contact.remove
  'contact/update': contact.update
  'contact/fetch-left': contact.fetchLeft

  'message/more': message.more
  'message/read': message.read
  'message/create': message.create
  'message/remove': message.remove
  'message/update': message.update
  'message/correct': message.correct
  'message/create-local': message.createLocal
  'message/receipt-loading': message.receiptLoading

  'settings/update': settings.update
  'settings/mark-login': settings.markLogin
  'settings/fold-contact': settings.foldContact
  'settings/unfold-contact': settings.unfoldContact
  'settings/team-footprints': settings.teamFootprints
  'settings/change-enter-method': settings.changeEnterMethod
  'settings/update-emoji-counts': settings.updateEmojiCounts

  'favorite/read': favorite.read
  'favorite/remove': favorite.remove
  'favorite/create': favorite.create

  'fav-result/read': favResult.read
  'fav-result/clear': favResult.clear

  'topic-prefs/push': topicPrefs.push
  'topic-prefs/update': topicPrefs.update

  'collection/file': collection.file
  'collection/post': collection.post
  'collection/link': collection.link
  'collection/snippet': collection.snippet

  'contact-prefs/push': contactPrefs.push
  'contact-prefs/update': contactPrefs.update

  'notify-banner/clear': notifyBanner.clear
  'notify-banner/create': notifyBanner.create

  'tagged-result/read': taggedResults.read
  'tagged-result/clear': taggedResults.clear

  'search-message/after': searchMessage.after
  'search-message/search': searchMessage.search
  'search-message/before': searchMessage.before

  'tagged-message/read': taggedMessage.read

  'file/create': file.create
  'file/progress': file.progress
  'file/success': file.success
  'file/error': file.error

  'story/create': story.create
  'story/leave': story.leave
  'story/join': story.join
  'story/read': story.read
  'story/readone': story.readone
  'story/remove': story.remove
  'story/update': story.update
  'story/create-draft': story.createDraft

  'notification/create': notification.create
  'notification/read': notification.read
  'notification/update': notification.update
  'notification/remove': notification.remove
  'notification/pre-clear-team-unread': notification.preClearTeamUnread
  'notification/post-clear-team-unread': notification.postClearTeamUnread

  'device/mark-channel': device.markChannel
  'device/toggle-markdown': device.toggleMarkdown
  'device/clearing-unread': device.clearingUnread
  'device/update-inbox-load-status': device.updateInboxLoadStatus

  'draft/story/delete': draft.deleteStoryDraft
  'draft/story/delete-all': draft.deleteAllStoryDraft
  'draft/story/update': draft.updateStoryDraft

  'settings/open-drawer': settings.openDrawer
  'settings/close-drawer': settings.closeDrawer

  'group/read': group.read
  'group/create': group.create
  'group/update': group.update
  'group/remove': group.remove

  'mentioned-message/clear': mentionedMessages.clear
  'mentioned-message/read': mentionedMessages.read

  'activities/read': activities.read
  'activities/create': activities.create
  'activities/update': activities.update
  'activities/remove': activities.remove
}

module.exports = (store, actionType, actionData) ->
  fn = methods[actionType]

  if fn
    fn(store, Immutable.fromJS(actionData))
  else
    throw new Error('updater method is undefined for ' + actionType)
