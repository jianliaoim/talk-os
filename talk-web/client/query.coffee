Immutable = require 'immutable'

exports.orList = (x) ->
  x or Immutable.List()

exports.orMap = (x) ->
  x or Immutable.Map()

exports.fileMessagesBy = (store, _teamId, _channelId) ->
  store.getIn ['fileMessages', _teamId, _channelId]

exports.linkMessagesBy = (store, _teamId, _channelId) ->
  store.getIn ['linkMessages', _teamId, _channelId]

exports.postMessagesBy = (store, _teamId, _channelId) ->
  store.getIn ['postMessages', _teamId, _channelId]

exports.snippetMessagesBy = (store, _teamId, _channelId) ->
  store.getIn ['snippetMessages', _teamId, _channelId]

exports.contactPrefsBy = (store, _teamId, _contactId) ->
  store.getIn ['contactPrefs', _teamId, _contactId]

exports.contactAliasBy = (store, _teamId, _contactId) ->
  store.getIn ['contactPrefs', _teamId, _contactId, 'alias']

exports.contactsBy = (store, _teamId) ->
  store.getIn(['contacts', _teamId]) or Immutable.List()

exports.contactsByOne = (store, _teamId, _targetId) ->
  if store.hasIn(['contacts', _teamId]) and store.hasIn(['leftContacts', _teamId])
    contact = store.getIn(['contacts', _teamId])?.find (contact) ->
      contact.get('_id') is _targetId
    contact or= store.getIn(['leftContacts', _teamId])?.find (contact) ->
      contact.get('_id') is _targetId
    contact or= Immutable.Map()
  else Immutable.Map()

exports.leftContactsBy = (store, _teamId) ->
  store.getIn ['leftContacts', _teamId]

exports.leftContactsByOne = (store, _teamId, _contactId) ->
  if store.getIn(['leftContacts', _teamId])?
    store.getIn(['leftContacts', _teamId]).find (contact) ->
      contact.get('_id') is _contactId
  else null

exports.invitationsBy = (store, _teamId) ->
  if store.hasIn ['invitations', _teamId]
    store.getIn ['invitations', _teamId]
  else
    Immutable.List()

exports.deviceByOffline = (store) ->
  store.getIn(['device', 'disconnection'])

exports.deviceLoadingStack = (store) ->
  store.getIn(['device', 'loadingStack'])

exports.isClearingUnread = (store, _teamId, _channelId) ->
  store.getIn(['device', 'isClearingUnread', _teamId, _channelId])

exports.getEditMessageId = (store) ->
  store.getIn(['device', 'editMessageId'])

exports.favResults = (store) ->
  store.get 'favResults'

exports.favoritesBy = (store, _teamId) ->
  store.getIn ['favorites', _teamId]

exports.foldedContacts = (store) ->
  store.getIn ['settings', 'foldedContacts']

exports.intesBy = (store, _teamId) ->
  store.getIn ['intes', _teamId]

exports.membersBy = (store, _teamId, _channelId) ->
  store.getIn(['members', _teamId, _channelId]) or Immutable.List()

exports.messagesBy = (store, _teamId, _channelId) ->
  store.getIn(['messages', _teamId, _channelId]) or Immutable.List()

exports.bannerNotices = (store) ->
  store.get 'bannerNotices'

exports.notices = (store) ->
  store.get('notices').toList()

exports.searchMessages = (store) ->
  store.get 'searchMessages'

exports.tagsBy = (store, _teamId) ->
  store.getIn ['tags', _teamId]

exports.taggedMessages = (store) ->
  store.get 'taggedMessages'

exports.taggedResults = (store) ->
  store.get 'taggedResults'

exports.teams = (store) ->
  store.get('teams')

exports.teamBy = (store, _teamId) ->
  store.getIn ['teams', _teamId]

exports.topicPrefsBy = (store, _teamId, _roomId) ->
  store.getIn ['topicPrefs', _teamId, _roomId]

exports.topicsBy = (store, _teamId) ->
  store.getIn ['topics', _teamId]

exports.topicsByOne = (store, _teamId, _roomId) ->
  if store.getIn(['topics', _teamId])?
    if _roomId?
      store.getIn(['topics', _teamId]).find (room) ->
        room.get('_id') is _roomId
    else
      store.getIn(['topics', _teamId]).find (room) ->
        room.get('isGeneral')
  else null

exports.allTopicsByOne = (store, _teamId, _roomId) ->
  hasRoom = (room) -> room.get('_id') is _roomId
  topic = store.getIn(['topics', _teamId])?.find hasRoom
  archivedTopic = store.getIn(['archivedTopics', _teamId])?.find hasRoom
  topic or archivedTopic

exports.archivedTopicsBy = (store, _teamId) ->
  store.getIn ['archivedTopics', _teamId]

exports.user = (store) ->
  store.get 'user'

exports.userId = (store) ->
  if store.get('user')?
    store.get('user').get('_id')
  else null

exports.prefs = (store) ->
  store.get 'prefs'

exports.draftsByPrefs = (store) ->
  store.getIn ['drafts', 'prefs']

exports.settings = (store) ->
  store.get 'settings'

exports.teamFootprints = (store) ->
  store.getIn ['settings', 'teamFootprints']

exports.enterMethod = (store) ->
  store.getIn ['settings', 'enterMethod']

exports.mostRecentEmojis = (store) ->
  defaultEmojis =
    thumbsup: 0
    clap: 0
    smile: 0
    joy: 0
    kissing_heart: 0
  counts = store.getIn(['settings', 'emojiCounts']) or Immutable.Map()
  counts = Immutable.Map(defaultEmojis).merge(counts)
  counts.map (count, emoji) ->
    emoji: emoji
    count: count
  .toList()
  .sortBy (e) ->
    -e.count
  .take(5)
  .map (e) ->
    e.emoji

exports.draftsDraftBy = (store, _teamId, _channelId) ->
  store.getIn ['drafts', 'draft', "#{_teamId}+#{_channelId}"]

exports.draftsPostBy = (store, _teamId, _channelId) ->
  store.getIn ['drafts', 'post', "#{_teamId}+#{_channelId}"]

exports.draftsSnippetBy = (store, _teamId, _channelId) ->
  store.getIn ['drafts', 'snippet', "#{_teamId}+#{_channelId}"]

exports.accounts = (store) ->
  store.get 'accounts'


# statement

exports.byChannelType = (_channelType) ->
  switch _channelType
    when 'chat' then exports.contactsByOne
    when 'room' then exports.allTopicsByOne
    when 'story' then exports.storiesByOne

# draft

exports.draftByOne = (store, _teamId, _channelId) ->
  store.getIn(['drafts', 'draft', "#{_teamId}+#{_channelId}"]) or ''

exports.draftMessageBy = (store, _teamId, _channelId) ->
  store.getIn([ 'drafts', 'draft', "#{ _teamId }+#{ _channelId }" ]) or ''

exports.draftStoryBy = (store, _draftStoryId) ->
  store.getIn(['drafts', 'stories', _draftStoryId]) or Immutable.Map()

# story

exports.stories = (store) ->
  store.get 'stories'

exports.storiesBy = (store, _teamId) ->
  store.getIn ['stories', _teamId]

exports.storiesByOne = (store, _teamId, _storyId) ->
  if store.hasIn(['stories', _teamId]) and _storyId?
    store.getIn(['stories', _teamId]).find (story) ->
      story.get('_id') is _storyId
  else Immutable.Map()

# notification

exports.notificationsBy = (store, _teamId) ->
  if store.hasIn ['notifications', _teamId]
    store.getIn ['notifications', _teamId]
  else Immutable.List()

exports.notificationsByOne = (store, _teamId, _channelId) ->
  notification = store.getIn(['notifications', _teamId])?.find (n) ->
    n.get('_targetId') is _channelId
  notification or Immutable.Map()

exports.thirdParties = (store) ->
  store.get 'thirdParties' or Immutable.List()

exports.userFromContacts = (store, _teamId) ->
  _userId = exports.userId(store)
  me = exports.contactsBy(store, _teamId).find (contact) ->
    contact.get('_id') is _userId

exports.userRole = (store, _teamId) ->
  _userId = exports.userId(store)
  me = exports.contactsBy(store, _teamId).find (contact) ->
    contact.get('_id') is _userId
  me?.get('role') or 'member'

# mothods with special purpose

exports.requestContactsByOne = (store, _teamId, _contactId) ->
  contact = store.getIn(['contacts', _teamId])?.find (contact) ->
    contact.get('_id') is _contactId
  contact or= store.getIn(['leftContacts', _teamId])?.find (contact) ->
    contact.get('_id') is _contactId
  contact

exports.requestContactsBy = (store, _teamId) ->
  currentContacts = store.getIn(['contacts', _teamId]) or Immutable.List()
  leftContacts = store.getIn(['leftContacts', _teamId]) or Immutable.List()
  currentContacts.concat leftContacts

exports.markdownStatus = (store) ->
  store.getIn [ 'drafts', 'activeMarkdown' ]

# Controls the open status of team-drawer.
#
# @param { Immutable.Map } store
#
# @return boolean

exports.drawerStatus = (store) ->
  store.getIn [ 'settings', 'showDrawer' ]

# Get story data from draft
#
# @param { string } key
#
# @return Immutable.Map

exports.storyDraftBy = (store, _teamId, storyCategory) ->
  store.getIn([ 'drafts', 'story', _teamId, storyCategory ]) or Immutable.Map()

exports.groupsBy = (store, _teamId) ->
  store.getIn(['groups', _teamId]) or Immutable.List()

exports.groupByOne = (store, _teamId, _groupId) ->
  store.getIn(['groups', _teamId])?.find (group) ->
    group.get('_id') is _groupId


###
 * Extract notification ID from its target id,
 * VERY HACK! VERY SHIT.
 *
 * @param {string} _teamId
 * @param {string} _targetId
 *
 * @return {string} _notyId
###

exports.notificationIdByTarget = (store, _teamId, _targetId) ->
  store
  .getIn [ 'notifications', _teamId ]
  .find (notification) ->
    notification.get('_targetId') is _targetId
  .get '_id'

exports.isTuned = (store) ->
  store.getIn ['device', 'isTuned']

exports.isFocused = (store) ->
  store.getIn ['device', 'isFocused']

exports.mentionedMessagesBy = (store, _teamId) ->
  store.getIn ['mentionedMessages', _teamId]

exports.inboxLoadStatus = (store, _teamId) ->
  if not store.hasIn ['device', 'inboxLoadStatus', _teamId]
    return false

  store.getIn ['device', 'inboxLoadStatus', _teamId]

# in guest page there's only one topic, hard code the path
exports.guestOnlyTopic = (store) ->
  store.get('topics').first().first()
