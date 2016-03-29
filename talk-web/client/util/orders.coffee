time = require './time'
detect = require './detect'

map =
  owner: 0
  admin: 1
  member: 2

exports.isGeneral = (a, b) ->
  if a.get('isGeneral') and (not b.get('isGeneral')) then return -1
  if (not a.get('isGeneral')) and b.get('isGeneral') then return 1
  return 0

exports.isRobot = (a, b) ->
  if a.get('isRobot') and (not b.get('isRobot')) then return -1
  if (not a.get('isRobot')) and b.get('isRobot') then return 1
  return 0

exports.unreadFirst = (a, b) ->
  switch
    when (a.get('unread') > 0) and (b.get('unread') is 0) then -1
    when (a.get('unread') is 0) and (b.get('unread') > 0) then 1
    when (a.get('unread') > b.get('unread') > 0) then -1
    when (b.get('unread') > a.get('unread') > 0) then 1
    else 0

exports.lastActive = (a, b) ->
  aActive = a.get('lastActive')?
  bActive = b.get('lastActive')?
  if aActive and bActive
    switch time.isBefore a.get('lastActive'), b.get('lastActive')
      when true then return 1
      when false then return -1
      else return 0
  if aActive and (not bActive) then return -1
  if bActive and (not aActive) then return 1
  return 0

exports.byKeyProp = (a, b) ->
  if a.key < b.key then return -1
  if a.key > b.key then return 1
  return 0

exports.byDate = (a, b) ->
  da = new Date a.get('createdAt')
  db = new Date b.get('createdAt')
  switch
    when da < db then -1
    when da > db then 1
    else 0

exports.byReverseDate = (a, b) ->
  da = new Date a.get('createdAt')
  db = new Date b.get('createdAt')
  switch
    when da < db then 1
    when da > db then -1
    else 0

exports.byUpdateDate = (a, b) ->
  da = new Date a.updatedAt
  db = new Date b.updatedAt
  switch
    when da < db then -1
    when da > db then 1
    else 0

exports.byReverseUpdateDate = (a, b) ->
  da = new Date a.updatedAt
  db = new Date b.updatedAt
  switch
    when da < db then 1
    when da > db then -1
    else 0

exports.byFavoriteDate = (a, b) ->
  da = new Date a.favoritedAt
  db = new Date b.favoritedAt
  switch
    when da < db then 1
    when da > db then -1
    else 0

exports.byRoleThenPinyin = (contactA, contactB) ->
  roleA = map[contactA.get('role')]
  roleB = map[contactB.get('role')]
  if roleA < roleB then return -1
  if roleA > roleB then return 1
  exports.byPinyin(contactA, contactB)

exports.byCreatorIdThenPinyin = (creatorId) -> (memberA, memberB) ->
  return -1 if memberA.get('_id') is creatorId
  return 1 if memberB.get('_id') is creatorId
  exports.byPinyin(memberA, memberB)

exports.bySmallerId = (a, b) ->
  switch
    when a < b then -1
    when a > b then 1
    else 0

exports.byGreaterId = (a, b) ->
  switch
    when a < b then 1
    when a > b then -1
    else 0

exports.byCreatedAtWithId = (a, b) ->
  # sort by createdAt with ._id, avoid same createdAt
  da = new Date a.createdAt
  db = new Date b.createdAt
  switch
    when da < db then return -1
    when da > db then return 1
    else
      switch
        when a._id < b._id then -1
        when a._id > b._id then 1
        else 0

exports.imMsgByPopRate = (a, b) ->
  switch
    when a.get('popRate') > b.get('popRate') then -1
    when a.get('popRate') < b.get('popRate') then 1
    else 0

exports.byPopularTeam = (footprints) -> (a, b) ->
  res = exports.unreadFirst a, b
  if res isnt 0 then return res
  footprintA = footprints.get(a.get('_id')) or 0
  footprintB = footprints.get(b.get('_id')) or 0
  if (footprintA > footprintB) then -1 else 1

# not good enough. return -1 when a is before b
exports.tellInt = (a, b) ->
  switch
    when a < b then -1
    when a > b then 1
    else 0

exports.imMsgBySmallerId = (a, b) ->
  idA = a.get('_id')
  idB = b.get('_id')
  exports.tellInt idA, idB

exports.imMsgByLargerId = (a, b) ->
  return -exports.imMsgBySmallerId(a, b)

exports.imMsgByCreatedAt = (a, b) ->
  idA = new Date a.get('createdAt')
  idB = new Date b.get('createdAt')
  exports.tellInt idA, idB

exports.imMsgByCreatedAtNew = (a, b) ->
  return -exports.imMsgByCreatedAt(a, b)

exports.isTagActive = (a, b, tagIds) ->
  aIsActive = tagIds.contains a.get('_id')
  bIsActive = tagIds.contains b.get('_id')
  switch
    when aIsActive and (not bIsActive) then -1
    when (not aIsActive) and bIsActive then 1
    else
      switch
        when a.get('createdAt') > b.get('createdAt') then -1
        when a.get('createdAt') < b.get('createdAt') then 1
        else 0

exports.imMsgByDate = (a, b) ->
  da = new Date a.get('createdAt')
  db = new Date b.get('createdAt')
  switch
    when da < db then -1
    when da > db then 1
    else 0

exports.imMsgByReverseDate = (a, b) ->
  da = new Date a.get('createdAt')
  db = new Date b.get('createdAt')
  switch
    when da < db then 1
    when da > db then -1
    else 0

exports.imMsgByCreatedAtWithId = (a, b) ->
  # sort by createdAt with ._id, avoid same createdAt
  da = new Date a.get('createdAt')
  db = new Date b.get('createdAt')
  switch
    when da < db then return -1
    when da > db then return 1
    else
      switch
        when a.get('_id') < b.get('_id') then -1
        when a.get('_id') > b.get('_id') then 1
        else 0

exports.byPinyin = (memberA, memberB) ->
  a = memberA.get('pinyin')
  b = memberB.get('pinyin')
  switch
    when a < b then -1
    when a > b then 1
    else 0

exports.isRoomQuit = (roomA, roomB) ->
  aIsQuit = not detect.inChannel(roomA)
  bIsQuit = not detect.inChannel(roomB)
  switch
    when bIsQuit and not aIsQuit then -1
    when aIsQuit and not bIsQuit then 1
    else 0

exports.byCreatorId = (creatorId) -> (memberA, memberB) ->
  return -1 if memberA.get('_id') is creatorId
  return 1 if memberB.get('_id') is creatorId
