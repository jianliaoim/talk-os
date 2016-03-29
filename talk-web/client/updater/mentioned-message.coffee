Immutable = require 'immutable'

isMap = Immutable.Map.isMap

# 根据 createdAt 排序搜索到的数据
sortByCreatedAt = (prev, next) ->
  if not (isMap(prev) and isMap(next))
    return 0

  if not (prev.has('createdAt') and next.has('createdAt'))
    return 0

  prevDate = new Date(prev.get('createdAt'))
  nextDate = new Date(next.get('createdAt'))
  nextDate - prevDate

###
 * 清除所有 mentioned messages
 *
 * @param {Immutable.Map} store
 * @param {params<Immutable.Map>}<Immutable.Map> incomingData
###
exports.clear = (store, incomingData) ->
  _teamId = incomingData.getIn ['params', '_teamId']

  store
  .update 'mentionedMessages', (teams) ->
    if not Immutable.Map.isMap teams
      teams = Immutable.Map()
    teams.set _teamId, Immutable.List()

###
 * API: http://talk.ci/doc/restful/message.mentions.html
 *
 * 读取对应的 mentions message
 *
 * @param {Immutable.Map} store
 * @param {params<Immutable.Map>, data<Immutable.List>}<Immutable.Map> incomingData
###

exports.read = (store, incomingData) ->
  _teamId = incomingData.getIn ['params', '_teamId']
  newMessages = incomingData.get('data') or Immutable.List()

  store
  .update 'mentionedMessages', (teams) ->
    if not Immutable.Map.isMap teams
      teams = Immutable.Map()
    teams.update _teamId, (messages) ->
      messages = messages or Immutable.List()
      messages
      .concat newMessages
      .sort sortByCreatedAt
