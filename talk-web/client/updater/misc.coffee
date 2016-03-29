
Immutable = require 'immutable'

schema = require '../schema'

teamRelatesFields = [
  'archivedTopics', 'contactPrefs', 'contacts', 'favorites'
  'intes', 'invitations', 'leftContacts', 'members', 'messages'
  'tags', 'topicPrefs', 'topics', 'stories', 'notifications',
  'groups'
]

# called on every network break and page close
exports.outdateStore = (store) ->
  router = store.get 'router'
  _teamId = router.getIn ['data', '_teamId']
  _roomId = router.getIn ['data', '_roomId']
  _toId = router.getIn ['data', '_toId']
  _storyId = router.getIn ['data', '_storyId']

  # clear data from store step by step, newStore is mutable reference
  newStore = store
  .set 'notices', Immutable.Map()
  .set 'bannerNotices', Immutable.Map()
  .set 'inteSettings', Immutable.List()
  .set 'device', schema.device
  # suppose there is a current team, clear data of other teams
  if _teamId?
    newStore = teamRelatesFields.reduce (acc, field) ->
      if newStore.hasIn([field, _teamId])
        acc.set(field, Immutable.Map())
        .setIn [field, _teamId], newStore.getIn([field, _teamId])
      else
        acc.set(field, Immutable.Map())
    , newStore
    # suppose a channel is focused, clear data of other channels
    _channelId = _roomId or _toId or _storyId
    if _channelId?
      currentMessages = newStore.getIn ['messages', _teamId, _channelId]
      newStore = newStore
      .setIn ['messages', _teamId], Immutable.Map()
      .setIn ['messages', _teamId, _channelId], currentMessages
    # otherwise, all messages can be cleared
    else
      newStore = newStore
      .setIn ['messages', _teamId], Immutable.Map()
  # otherwise, all fields can be cleared
  else
    teamRelatesFields.forEach (field) ->
      newStore = newStore.set field, Immutable.Map()

  # new store should be much smaller
  newStore
