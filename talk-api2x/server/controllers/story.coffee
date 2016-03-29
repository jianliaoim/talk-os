_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'
limbo = require 'limbo'
logger = require 'graceful-logger'

app = require '../server'
storySearcher = require '../searchers/story'

{
  StoryModel
  UserModel
  MessageModel
  NotificationModel
  ActivityModel
} = limbo.use 'talk'

module.exports = storyController = app.controller 'story', ->

  editableFields = ['addMembers', 'removeMembers', 'data']

  @mixin require './mixins/permission'

  @ratelimit '60 300', only: 'search'

  @ensure '_teamId category data', only: 'create'
  @ensure '_teamId', only: 'read search'

  @least editableFields, only: 'update'

  @before 'isTeamMember', only: 'create read search'
  @before 'readableStory', only: 'readOne leave'
  @before 'beforeUpdateStory', only: 'update'
  @before 'editableStory', only: 'remove'

  @after 'populateStory', only: 'create readOne update leave'
  # Create notifications
  @after 'afterCreate', only: 'create', parallel: true
  @after 'createActivityAfterCreate', only: 'create', parallel: true
  # Create update story message
  # Create new notifications if add members
  # Create inviting message if add/remove members
  @after 'afterUpdate', only: 'update', parallel: true
  @after 'updateActivitiesAfterUpdate', only: 'update', parallel: true
  # Remove notifications
  @after 'afterLeave', only: 'leave', parallel: true
  # Remove notifications
  @after 'afterRemove', only: 'remove', parallel: true
  @after 'removeActivitiesAfterRemove', only: 'remove', parallel: true

  @action 'create', (req, res, callback) ->
    {_sessionUserId, socketId} = req.get()
    story = new StoryModel req.get()
    story._creatorId = _sessionUserId
    story.socketId = socketId
    story.save (err, story) -> callback err, story

  @action 'update', (req, res, callback) ->
    {socketId, story, data} = req.get()
    update = _.pick req.get(), editableFields

    if update.addMembers?.length
      story.members = _.uniq story.members.concat(update.addMembers)

    if update.removeMembers?.length
      story.members = story.members.filter (_memberId) -> "#{_memberId}" not in update.removeMembers

    unless _.isEmpty data
      dataModel = story.data
      dataModel[key] = val for key, val of data
      story.data = dataModel

    story.socketId = socketId
    story.updatedAt = new Date
    story.save (err, story) -> callback err, story

  @action 'readOne', (req, res, callback) -> callback null, req.get('story')

  @action 'read', (req, res, callback) ->
    StoryModel.findByOptions req.get(), callback

  @action 'remove', (req, res, callback) ->
    {socketId, story} = req.get()
    story.socketId = socketId
    story.remove (err, story) -> callback err, story

  ###*
   * Quit discussion of story
  ###
  @action 'leave', (req, res, callback) ->
    {_sessionUserId, story} = req.get()
    req.set 'removeMembers', [_sessionUserId]
    @update req, res, callback

  @action 'search', (req, res, callback) ->
    storySearcher.search req, res, callback

################################ HOOKS ################################

  @action 'populateStory', (req, res, story, callback) -> story.getPopulated callback

  # Create update story message
  # Create new notifications if add members
  # Create inviting message if add/remove members
  @action 'afterUpdate', (req, res, story) ->
    {_sessionUserId, addMembers, removeMembers, data} = req.get()

    $contentChanged = Promise.resolve().then ->
      message = new MessageModel
        creator: _sessionUserId
        team: story._teamId
        story: story._id
        isSystem: true
        icon: 'update-room'
      updates = []
      ['title', 'fileName', 'text', 'url'].forEach (key) ->
        if data?[key]
          if data[key].length > 20
            update = data[key][0...20] + '...'
          else
            update = data[key]
          updates.push update
      if updates.length
        updates.unshift "{{__info-update-story}}"
        message.body = updates.join ' '
        $changed = message.$save().then -> true
      else
        $changed = Promise.resolve false
      $changed

    # Broadcast member change message
    # Update notification if member was not existing in the story
    $memberChange = $contentChanged.then (contentChanged) ->
      # Do not broadcast member change infomation when story's content was modified
      return if contentChanged

      message = new MessageModel
        creator: _sessionUserId
        team: story._teamId
        story: story._id
        isSystem: true
        icon: 'join-room'

      if addMembers?.length
        $memberNames = UserModel.findAsync _id: $in: addMembers, 'name'
        .map (user) -> "#{user.name}"
        .then (userNames) -> userNames.join ', '

        $addMemberMessage = $memberNames.then (memberNames) ->
          messageBody = "{{__info-invite-members}} #{memberNames}"
          message.body = if message.body then "#{message.body}, #{messageBody}" else messageBody

        $addMembers = $addMemberMessage
      else
        $addMembers = Promise.resolve()

      if removeMembers?.length
        $memberNames = UserModel.findAsync _id: $in: removeMembers, 'name'
        .map (user) -> "#{user.name}"
        .then (userNames) -> userNames.join ', '

        $removeMemberMessage = $memberNames.then (memberNames) ->
          messageBody = "{{__info-remove-members}} #{memberNames}"
          message.icon = 'leave-room'
          message.body = if message.body then "#{message.body}, #{messageBody}" else messageBody

        # Remove notifications when remove members
        $removeMemberNotifications = Promise.resolve(removeMembers).map (_userId) ->
          NotificationModel.updateByOptionsAsync
            target: story._id
            type: 'story'
            user: _userId
            team: story._teamId
          , isHidden: true

        $removeMembers = Promise.all [$removeMemberMessage, $removeMemberNotifications]
      else
        $removeMembers = Promise.resolve()

      $message = Promise.all [$addMembers, $removeMembers]
      .then -> message.$save() if message.body?.length

      Promise.all [$addMembers, $removeMembers, $message]

    Promise.all [$memberChange, $contentChanged]
    .catch (err) -> logger.warn err.stack

  @action 'afterCreate', (req, res, story) ->
    {_sessionUserId} = req.get()
    $notifications = Promise.resolve(story._memberIds).map (_userId) ->
      NotificationModel.createByOptionsAsync
        text: "{{__info-create-story}} #{story.title?[0...30] or ''}"
        user: _userId
        team: story._teamId
        target: story._id
        type: 'story'
        creator: _sessionUserId
        updatedAt: new Date
        needPush: true
    $notifications.catch (err) -> logger.warn err.stack

  @action 'afterLeave', (req, res, story) ->
    {_sessionUserId} = req.get()

    $removeNotifications = NotificationModel.updateByOptionsAsync
      target: story._id
      type: 'story'
      user: _sessionUserId
      team: story._teamId
    , isHidden: true

    $message = Promise.resolve().then ->
      message = new MessageModel
        creator: _sessionUserId
        team: story._teamId
        story: story._id
        isSystem: true
        body: '{{__info-leave-story}}'
        icon: 'leave-room'
      message.$save()

    Promise.all [$removeNotifications, $message]
    .catch (err) -> logger.warn err.stack

  @action 'afterRemove', (req, res, story) ->
    {_sessionUserId} = req.get()
    NotificationModel.removeByOptionsAsync
      target: story._id
      type: 'story'
      team: story._teamId
    .catch (err) -> logger.warn err.stack

  @action 'createActivityAfterCreate', (req, res, story) ->

    activity = new ActivityModel
      team: story._teamId
      target: story._id
      type: 'story'
      creator: story._creatorId
      isPublic: story.isPublic

    switch story.category
      when 'topic' then activity.text = '{{__info-create-topic-story}}'
      when 'file' then activity.text = '{{__info-create-file-story}}'
      when 'link' then activity.text = '{{__info-create-link-story}}'
      else return

    unless activity.isPublic
      activity.members = story._memberIds

    activity.$save().catch (err) -> logger.warn err.stack

  @action 'updateActivitiesAfterUpdate', (req, res, story) ->
    checkFields = ['isPublic', 'data', 'addMembers', 'removeMembers']
    return unless (checkFields.some (key) -> req.get(key)?)

    $activities = ActivityModel.findAsync target: story._id

    .map (activity) ->
      activity.isPublic = story.isPublic
      activity.text = "{{__info-create-story}} #{story.title?[0...30] or ''}"
      if activity.isPublic
        activity.members = []
      else
        activity.members = story._memberIds

      activity.$save()

    .catch (err) -> logger.warn err.stack

  @action 'removeActivitiesAfterRemove', (req, res, story) ->
    return unless story?._id and story?._teamId
    ActivityModel.removeAsync
      target: story._id
    .catch (err) -> logger.warn err.stack
