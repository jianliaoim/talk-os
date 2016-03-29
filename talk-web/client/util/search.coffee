Immutable = require 'immutable'

lang = require '../locales/lang'
detect = require '../util/detect'
pinyinUtil = require '../util/pinyin'

xiaoaiPinyin = Immutable.fromJS
  pinyin: 'xiaoai'
  pinyins: ['xiaoai', 'xiaoyi']
  py: 'xa'
  pys: ['xa', 'xy']

generalPinyin =
  pinyin: 'gonggaoban'
  pinyins: Immutable.List(['gonggaoban', '公告板', 'ggb'])
  py: 'ggb'
  pys: Immutable.List(['ggb'])

indexOfPinyins = (pinyins, query) ->
  return -1 if not pinyins
  if pinyins.first() is 'general'
    pinyins = pinyins.concat(generalPinyin.pinyins)
  pos = pinyins
    .map (pinyin) ->
      pinyin.indexOf(query)
    .filter (pos) ->
      pos >= 0
    .min()
  if pos >= 0 then pos else -1

exports.indexOfPinyins = indexOfPinyins

exports.forMember = (member, query, opt = {}) ->
  searchQuery = query.toLowerCase()
  if detect.isTalkai(member)
    member = member.merge(xiaoaiPinyin)
  return true if member.get('name')?.toLowerCase().indexOf(searchQuery) >= 0
  return true if indexOfPinyins(member.get('pinyins'), searchQuery) >= 0
  return true if indexOfPinyins(member.get('pys'), searchQuery) >= 0
  alias = opt.getAlias?(member.get('_id'))?.toLowerCase()
  if alias
    aliasPinyin = pinyinUtil.make(alias)
    return true if alias.indexOf(searchQuery) >= 0
    return true if indexOfPinyins(aliasPinyin.get('pinyins'), searchQuery) >= 0
    return true if indexOfPinyins(aliasPinyin.get('pys'), searchQuery) >= 0
  return false

exports.forTopic = (topic, query) ->
  searchQuery = query.toLowerCase()
  return true if topic.get('topic')?.toLowerCase().indexOf(searchQuery) >= 0
  return true if indexOfPinyins(topic.get('pinyins'), searchQuery) >= 0
  return true if indexOfPinyins(topic.get('pys'), searchQuery) >= 0
  return false

exports.forStory = (story, query) ->
  return false if not story.get('title')
  searchQuery = query.toLowerCase()
  return true if story.get('title').toLowerCase().indexOf(searchQuery) >= 0
  titlePinyin = pinyinUtil.make(story.get('title'))
  return true if indexOfPinyins(titlePinyin.get('pinyins'), searchQuery) >= 0
  return true if indexOfPinyins(titlePinyin.get('pys'), searchQuery) >= 0
  return false

exports.forMembers = (members, query, opt = {}) ->
  searchQuery = query.toLowerCase()
  members
    .filter (item) ->
      exports.forMember(item, query, opt)

exports.forInvitations = (invitations, query) ->
  searchQuery = query.toLowerCase()

  invitations
  .filter (invitation) ->
    pa = invitation.get('name')?.toLowerCase().indexOf(searchQuery)
    invitation.set 'pos', pa

    pa >= 0
  .sort (a, b) ->
    a.get('pos') - b.get('pos')

exports.forTopics = (topics, query) ->
  topics
  .filter (item) ->
    exports.forTopic(item, query)

exports.forEmojis = (emojis, query) ->
  emojis.filter (name) ->
    name.indexOf(query) is 0

exports.forTags = (tags, query) ->
  searchQuery = query.trim().toLowerCase()
  if searchQuery.length > 0
    tags.filter (tag) ->
      tag.get('name').toLowerCase().indexOf(searchQuery) >= 0
  else
    tags

# see util/configs-inte for styles
exports.inteNames = (names, query) ->
  searchQuery = query.trim()
  if searchQuery.length is 0
    return names
  names
  .filter (name) ->
    if name.id.toLowerCase().indexOf(searchQuery) >= 0 then return true
    if name.name.toLowerCase().indexOf(searchQuery) >= 0 then return true
    return false

exports.immutableInteNames = (intes, query, language) ->
  searchQuery = query.trim()
  if searchQuery.length is 0
    return intes
  intes.filter (inte) ->
    if inte.get('name').toLowerCase().indexOf(searchQuery) >= 0 then return true
    if inte.get('title').toLowerCase().indexOf(searchQuery) >= 0 then return true
    summary = inte.get('summary').get(language)
    if summary.toLowerCase().indexOf(searchQuery) >= 0 then return true
    return false

exports.inteItems = (items, query, topics) ->
  searchQuery = query.trim()
  if searchQuery.length is 0
    return items
  items.filter (item) ->
    if item.get('title')?.toLowerCase().indexOf(searchQuery) >= 0 then return true
    if item.get('showname')?.toLowerCase().indexOf(searchQuery) >= 0 then return true
    if item.get('description')?.toLowerCase().indexOf(searchQuery) >= 0 then return true
    if item.get('category').toLowerCase().indexOf(searchQuery) >= 0 then return true
    topic = topics.find (topic) -> topic.get('_id') is item.get('_roomId')
    if topic?
      if topic.get('topic').toLowerCase().indexOf(searchQuery) >= 0 then return true
      if topic.get('isGeneral')
        locale = lang.getText('room-general')
        if locale.toLowerCase().indexOf(searchQuery) >= 0 then return true
    return false

exports.inKeyword = (collection, keyword, opt = {}) ->
  keyword = keyword.toLowerCase()
  collection
    .filter (item) ->
      exports.forMember(item, keyword, opt) or exports.forTopic(item, keyword)
