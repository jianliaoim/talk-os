# 更新 置顶 到 notification

startTime = ISODate()
print "任务开始", startTime.toISOString()
userruntimes = db.userruntimes.find pinnedAts: $ne: null

createNum = 0
updateNum = 0

userruntimes.forEach (userruntime) ->
  for _teamId, teamPinnedAts of userruntime.pinnedAts

    for _targetId, pinnedAt of teamPinnedAts

      pinnedAt = new Date pinnedAt

      room = db.rooms.findOne _id: ObjectId(_targetId)
      if room
        type = 'room'
      else
        user = db.users.findOne _id: ObjectId(_targetId)
        if user
          type = 'dms'

      continue unless type and pinnedAt

      conditions =
        user: userruntime._id
        team: ObjectId(_teamId)
        target: ObjectId(_targetId)

      notification = db.notifications.findOne conditions

      continue if notification?.isPinned

      existing = true
      unless notification
        existing = false
        notification = conditions
        notification._id = ObjectId()

      notification.type = type
      notification.creator ?= userruntime._id
      notification.text ?= ''
      notification.isMute ?= false
      notification.unreadNum ?= 0
      notification.isPinned = true
      notification.pinnedAt ?= pinnedAt
      notification.createdAt ?= new Date
      notification.updatedAt ?= new Date
      notification.isHidden = false

      if existing
        updateNum += 1
      else
        createNum += 1

      db.notifications.save notification

print "置顶更新数", updateNum
print "置顶新建数", createNum

# 更新 静音 到 notification

members = db.members.find({room: {$ne: null}, 'prefs.isMute': true})

createNum = 0
updateNum = 0

members.forEach (member) ->

  room = db.rooms.findOne _id: member.room

  return unless room?.team

  conditions =
    target: room._id
    team: room.team
    user: member.user
    type: 'room'

  notification = db.notifications.findOne conditions

  return if notification?.isMute

  existing = true

  unless notification
    existing = false
    notification = conditions
    notification._id = ObjectId()

  notification.creator ?= member.user
  notification.text ?= ''
  notification.unreadNum ?= 0
  notification.isPinned ?= false
  notification.isMute = true
  notification.createdAt ?= new Date
  notification.updatedAt ?= new Date
  notification.isHidden ?= true

  if existing
    updateNum += 1
  else
    createNum += 1

  db.notifications.save(notification)

print "静音更新数", updateNum
print "静音新建数", createNum

# 更新 最新消息 到 notification
msgNum = 0
## 跳过重复 target 的消息
msgMap = {}

createNum = 0
processedNum = 0

messages = db.messages.find().sort({_id: -1}).limit(1000000)

messages.forEach (message) ->
  processedNum += 1
  print "执行记录数", processedNum if (processedNum % 10000) is 0
  # 跳过系统消息
  return if message.isSystem

  switch
    when message.body
      notifyText = message.body[0..50]
    when message.attachments?[0]?.data?.fileName
      notifyText = "{{__info-upload-files}} #{message.attachments[0].data.fileName}"
    when message.attachments?[0]?.data?.title
      notifyText = message.attachments[0].data.title[0..50]
    when message.attachments?[0]?.data?.text
      notifyText = message.attachments[0].data.text[0..50]
    when message.attachments?[0]?.category is 'speech'
      notifyText = '{{__info-new-speech}}'

  switch
    when message.room
      # 跳过已处理的消息
      return if msgMap["#{message.room}"]
      msgMap["#{message.room}"] = 1

      room = db.rooms.findOne({_id: message.room}, {_id: 1, team: 1, isArchived: 1})
      return unless room and not room.isArchived

      members = db.members.find
        room: message.room
        isQuit: false
      , user: 1

      members.forEach (member) ->

        conditions =
          user: member.user
          team: message.team
          target: room._id
          type: 'room'

        notification = db.notifications.findOne conditions
        return if notification

        notification = conditions
        notification._id = ObjectId()
        notification.creator = message.creator
        notification.text = notifyText
        notification.isMute = false
        notification.unreadNum = 0
        notification.isPinned = false
        notification.createdAt = message.createdAt
        notification.updatedAt = message.updatedAt
        notification.isHidden = false

        createNum += 1
        db.notifications.save notification

    when message.story
      # 跳过已处理的消息
      return if msgMap["#{message.story}"]
      msgMap["#{message.story}"] = 1
      story = db.stories.findOne({_id: message.story}, {_id: 1, team: 1, members: 1})
      return unless story

      story.members?.forEach (_userId) ->
        conditions =
          user: _userId
          team: message.team
          target: message.story
          type: 'story'

        notification = db.notifications.findOne conditions
        return if notification

        notification = conditions
        notification._id = ObjectId()
        notification.creator = message.creator
        notification.text = notifyText
        notification.isMute = false
        notification.unreadNum = 0
        notification.isPinned = false
        notification.createdAt = message.createdAt
        notification.updatedAt = message.updatedAt
        notification.isHidden = false

        createNum += 1
        db.notifications.save notification

    when message.to
      # 跳过已处理的消息
      idxKey = ["#{message.creator}", "#{message.to}"]
        .sort (a, b) -> if a > b then 1 else -1
        .join ''
      return if msgMap[idxKey]
      msgMap[idxKey] = 1

      [message.creator, message.to].forEach (_userId, i) ->
        conditions =
          user: _userId
          team: message.team
          target: if i is 0 then message.to else message.creator
          type: 'dms'

        notification = db.notifications.findOne conditions
        return if notification

        notification = conditions
        notification._id = ObjectId()
        notification.creator = message.creator
        notification.text = notifyText
        notification.isMute = false
        notification.unreadNum = 0
        notification.isPinned = false
        notification.createdAt = message.createdAt
        notification.updatedAt = message.updatedAt
        notification.isHidden = false

        createNum += 1
        db.notifications.save notification

    else return

print "创建通知数", createNum

endTime = ISODate()
print "任务结束", endTime.toISOString()
print "总用时", Math.floor((endTime - startTime) / 1000), '秒'
