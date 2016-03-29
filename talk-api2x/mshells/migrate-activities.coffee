_startId = ObjectId(Math.round(ISODate("2016-02-29T16:00:00.000Z") / 1000).toString(16) + new Array(17).join('0'))

rooms = db.rooms.find
  _id: $gt: _startId
  isGeneral: false
  isArchived: false

rooms.forEach (room) ->
  activity = db.activities.findOne target: room._id
  return if activity
  activity =
    team: room.team
    target: room._id
    type: 'room'
    creator: room.creator
    text: "{{__info-create-room}}"
    createdAt: room.createdAt
    updatedAt: room.createdAt

  if room.isPrivate
    activity.isPublic = false
    roomMembers = db.members.find
      room: room._id
      isQuit: false
    ,
      user: 1
    activity.members = roomMembers.map (member) ->
      member.user
    .filter (memberId) -> memberId
  else
    activity.isPublic = true

  print '保存动态', room._id
  db.activities.save(activity)

stories = db.stories.find
  _id: $gt: _startId

stories.forEach (story) ->
  activity = db.activities.findOne target: story._id
  return if activity

  activity =
    team: story.team
    target: story._id
    type: 'story'
    creator: story.creator
    isPublic: story.isPublic
    createdAt: story.createdAt
    updatedAt: story.createdAt

  activity.members = story.members if story.members?.length

  switch story.category
    when 'topic' then activity.text = '{{__info-create-topic-story}}'
    when 'file' then activity.text = '{{__info-create-file-story}}'
    when 'link' then activity.text = '{{__info-create-link-story}}'
    else return

  print '保存动态', story._id
  db.activities.save(activity)
