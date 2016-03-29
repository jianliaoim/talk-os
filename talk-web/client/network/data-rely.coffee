shortid = require 'shortid'
recorder = require 'actions-recorder'

schedule = require '../util/schedule'

actions = require '../actions/index'
tagActions = require '../actions/tag'
inteActions = require '../actions/inte'
teamActions = require '../actions/team'
roomActions = require '../actions/room'
storyActions = require '../actions/story'
groupActions = require '../actions/group'
searchActions = require '../actions/search'
accountActions = require '../actions/account'
contactActions = require '../actions/contact'
messageActions = require '../actions/message'
favoriteActions = require '../actions/favorite'
activitiesActions = require '../actions/activities'
notificationActions = require '../actions/notification'
searchMessageActions = require '../actions/search-message'
mentionedMessageActions = require '../actions/mentioned-message'

# rely data sources

exports.relyTeamsList = ->
  store = recorder.getState()

  kind: 'teamsList'
  isSatisfied: store.get('teams').size > 1
  request: (resolve, reject) ->
    teamActions.teamsFetch resolve, reject

exports.relyTeamTopics = (_teamId) ->
  store = recorder.getState()

  kind: 'topics'
  isSatisfied: store.getIn(['topics', _teamId])?
  request: (resolve, reject) ->
    teamActions.teamTopics _teamId, resolve, reject

exports.relyTeamMembers = (_teamId) ->
  store = recorder.getState()

  kind: 'contacts'
  isSatisfied: store.getIn(['contacts', _teamId])?
  request: (resolve, reject) ->
    teamActions.teamMembers _teamId, resolve, reject

exports.relyTeamInvitaitons = (_teamId) ->
  store = recorder.getState()

  kind: 'invitations'
  isSatisfied: store.getIn(['invitations', _teamId])?
  request: (resolve, reject) ->
    teamActions.teamInvitations _teamId, resolve, reject

exports.relyTeamActivities = (_teamId) ->
  store = recorder.getStore()

  kind: 'activities'
  isSatisfied: store.getIn(['activities', _teamId])?
  request: (resolve, reject) ->
    activitiesActions.get _teamId, null, resolve, reject

exports.relyTopicMessages = (_teamId, _roomId) ->
  store = recorder.getState()

  kind: 'topics.messages'
  isSatisfied: store.getIn(['messages', _teamId, _roomId])?
  request: (resolve, reject) ->
    roomActions.fetch _roomId, resolve, reject

exports.archivedTopics = (_teamId, _roomId) ->
  store = recorder.getState()

  kind: 'archivedTopics'
  isSatisfied: store.getIn(['archivedTopics', _teamId])?
  request: (resolve, reject) ->
    teamActions.getArchivedTopics _teamId, resolve, reject

exports.relyContactMessages = (_teamId, _toId) ->
  store = recorder.getState()

  kind: 'contacts.messages'
  isSatisfied: store.getIn(['messages', _teamId, _toId])?
  request: (resolve, reject) ->
    messageActions.messageReadChat _teamId, _toId, resolve, reject

exports.relyLeftContacts = (_teamId) ->
  store = recorder.getState()

  kind: 'leftContacts'
  isSatisfied: store.getIn(['leftContacts', _teamId])?
  request: (resolve, reject) ->
    contactActions.fetchLeftContacts _teamId, resolve, reject

exports.relyTags = (_teamId) ->
  store = recorder.getState()

  kind: 'tags'
  isSatisfied: store.getIn(['tags', _teamId])?
  request: (resolve, reject) ->
    tagActions.readTag _teamId, resolve, reject

exports.relyIntes = (_teamId) ->
  store = recorder.getState()

  kind: 'intes'
  isSatisfied: store.getIn(['intes', _teamId])?
  request: (resolve, reject) ->
    inteActions.inteFetch _teamId, resolve, reject

exports.relyFavorites = (_teamId) ->
  store = recorder.getState()

  kind: 'favorites'
  isSatisfied: store.getIn(['favorites', _teamId])?
  request: (resolve, reject) ->
    favoriteActions.readFavorite _teamId, resolve, reject

exports.relyTaggedMessages = (data) ->
  kind: 'taggedMessages'
  isSatisfied: false
  request: (resolve, reject) ->
    searchActions.messageTagged data, resolve, reject

exports.relyFavoriteResults = (data) ->
  kind: 'favoriteResults'
  isSatisfied: false
  request: (resolve, reject) ->
    favoriteActions.clearResults()
    favoriteActions.searchFavorite data, resolve, reject

exports.relyTaggedResults = (data) ->
  kind: 'taggedResults'
  isSatisfied: false
  request: (resolve, reject) ->
    tagActions.clearResults()
    tagActions.searchTagged data, resolve, reject

exports.relyMessageSearch = (data) ->
  kind: 'messageSearch'
  isSatisfied: false
  request: (resolve, reject) ->
    searchMessageActions.search data, resolve, reject

# account

exports.accounts = ->
  store = recorder.getState()

  kind: 'accounts'
  isSatisfied: store.get('accounts').size > 0
  request: (resolve, reject) ->
    accountActions.fetch resolve, reject

# contact

exports.contacts = (_teamId) ->
  store = recorder.getState()

  kind: 'contacts'
  isSatisfied: store.hasIn ['contacts', _teamId]
  request: (resolve, reject) ->
    contactActions.read _teamId, resolve, reject

# message

exports.messages = (_teamId, _channelId, _channelType) ->
  store = recorder.getState()

  kind: 'messages'
  isSatisfied: store.hasIn(['messages', _teamId, _channelId])
  request: (resolve, reject) ->
    messageActions.read _teamId, _channelId, _channelType, resolve, reject

exports.mentionedMessages = (params) ->
  kind: 'mentionedMessages'
  isSatisfied: false
  request: (resolve, reject) ->
    mentionedMessageActions.clear params
    mentionedMessageActions.read params, resolve, reject

### NOTIFICATIONS ###

###
 * Data rely of notification.
 * First of all, read all notification,
 * then check if the selected notification is exist.
 *
 * @param {string} _teamId
 * @param {string} _targetId
 *
 * @return null
###

exports.notifications = (_teamId, _targetId, type) ->
  store = recorder.getState()

  inCollection = ->
    store.getIn [ 'notifications', _teamId ]
    .some (item) ->
      isHidden = item.get 'isHidden'
      isTarget = item.get('_targetId') is _targetId
      not isHidden and isTarget

  # check if the notificaitons exists.
  hasNoties = store.getIn([ 'notifications', _teamId ])?.size > 0

  # specific the position of target notification.
  hasNoty = hasNoties and inCollection()

  hasTarget = _targetId?

  isSatisfied: if hasTarget then hasNoty else hasNoties
  request: (resolve, reject) ->
    if hasTarget
      if not hasNoties
        readNoty = ->
          notificationActions.create _teamId, _targetId, type, resolve, reject

        notificationActions.read _teamId, {}, readNoty, reject
      else if not hasNoty
        notificationActions.create _teamId, _targetId, type, resolve, reject
    else
      if not hasNoties
        notificationActions.read _teamId, {}, resolve, reject

# story

exports.story = (_teamId, _storyId) ->
  store = recorder.getState()
  inCollection = (item) -> item.get('_id') is _storyId

  kind: 'story'
  isSatisfied: store.hasIn(['stories', _teamId]) and store.getIn(['stories', _teamId]).some(inCollection)
  request: (resolve, reject) ->
    storyActions.readone _storyId, resolve, reject

exports.stories = (_teamId) ->
  store = recorder.getState()

  kind: 'stories'
  isSatisfied: store.hasIn(['stories', _teamId])
  request: (resolve, reject) ->
    storyActions.read _teamId, {}, resolve, reject

# team

exports.relyGroups = (_teamId) ->
  store = recorder.getState()

  kind: 'groups'
  isSatisfied: store.hasIn ['groups', _teamId]
  request: (resolve, reject) ->
    groupActions.read _teamId, resolve, reject

exports.relyThirdParties = (refer) ->
  store = recorder.getState()

  kind: 'thirds'
  isSatisfied: false
  request: (resolve, reject) ->
    teamActions.getThirds refer, resolve, reject

exports.relyInteSettings = ->
  store = recorder.getStore()

  kind: 'inte-settings'
  isSatisfied: store.get('inteSettings').size > 0
  request: (resolve, reject) ->
    actions.inte.getSettings resolve, reject

# final caller

exports.ensure = (deps, fn) ->
  unmatchedDeps = deps.filter (dependency) ->
    return false unless dependency? # might be undefined
    not dependency.isSatisfied
  depsKind = unmatchedDeps.map (dependency) -> dependency.kind
  calls = unmatchedDeps.map (dependency) -> dependency.request

  if calls.length > 0
    schedule.all calls, (results) ->
      fn results
  else
    fn calls
