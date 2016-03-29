# 清空发烧友不活跃用户
today = ISODate().getTime()
_teamId = ObjectId('544f9896480ab1825e6a1fc3')
members = db.members.find({team: _teamId})
memberCount = db.members.count({team: _teamId})
_roomIds = db.rooms.find({team: _teamId}).map (room) -> room._id
robotIds = db.users.find({isRobot: true}).map (robot) -> "#{robot._id}"

print "开始时间", ISODate()
print "总人数 #{memberCount}"
print "总话题数", _roomIds.length
print "机器人数", robotIds.length

skippedNum = 0
removedNum = 0
oldUserNum = 0

skip = (member) ->
  skippedNum += 1
  print "跳过 #{member.user}"

remove = (member) ->
  db.members.remove _id: member._id
  remRoom = db.members.remove user: member.user, room: $in: _roomIds
  removedNum += 1
  print "移除 #{member.user} 移除话题 #{remRoom.nRemoved}"

members.forEach (member) ->
  if member.isQuit
    return remove member
  if member.createdAt > today - 86400000 * 7
    # 跳过最近一周内加入成员
    return skip member
  if "#{member.user}" in robotIds
    # 跳过机器人
    return skip member
  if member.role in ['admin', 'owner']
    # 跳过管理员
    return skip member
  messages = db.messages.find({creator: member.user, team: member.team, isSystem: false})
    .sort({_id: -1}).limit(1)
  if messages?[0]?.createdAt > today - 86400000 * 30
    oldUserNum += 1
    # 保留 30 天内发言用户
    return skip member
  remove member

print "跳过人数", skippedNum
print "移除人数", removedNum
print "跳过老用户", oldUserNum
print "结束时间", ISODate()
