Promise = require 'bluebird'
_ = require 'lodash'
Err = require 'err1st'
moment = require 'moment'
util = require '../util'
{limbo} = require '../components'

{
  RoomModel
  TeamModel
  MessageModel
  MemberModel
  StoryModel
  SearchMessageModel
} = limbo.use 'talk'

_combileFilter = (filter = {}, clause, children) ->
  if filter.bool?[clause]
    filter.bool[clause].push children
  else if filter.bool
    filter.bool[clause] = [children]
  else
    _filter = filter
    filter = bool: {}
    filter.bool[clause] = [_filter, children]
  filter

_generalQueryDsl = (req) ->
  {
    _teamId
    keyword
    _sessionUserId
    limit
    page
    _creatorId
    _creatorIds
    _toId
    _toIds
    _roomId  # Room filter
    isDirectMessage  # Only return the direct messages
    type
    sort
    _tagId
    _storyId
    hasTag
    timeRange
  } = req.get()

  limit or= 10
  page or= 1
  page = parseInt page
  type or= 'general'

  return Promise.reject(new Err('OUT_OF_SEARCH_RANGE')) unless page > 0 and page <= 30

  mainFilterKeys = ['_roomId', 'isDirectMessage', '_storyId']

  mainFilters = mainFilterKeys.filter (key) -> req.get key

  return Promise.reject(new Err('PARAMS_CONFLICT', mainFilterKeys)) if mainFilters.length > 1

  keyword = keyword?.trim()
  keyword = keyword[..20] if keyword?.length > 20

  # Get room messages filter
  unless _storyId or isDirectMessage  # Do not read room member ids when look for direct messages
    if _roomId
      $rmFilter = MemberModel.findOneAsync
        user: _sessionUserId
        room: _roomId
        isQuit: false
      , '_id'
      .then (member) ->
        throw new Err('MEMBER_CHECK_FAIL', "Room #{_roomId}") unless member
        rmFilter = term: _roomId: _roomId
    else
      $rmFilter = TeamModel.findJoinedRoomIdsAsync _teamId, _sessionUserId
      .then (_roomIds) -> rmFilter = terms: _roomId: _roomIds

  # Get story filter, do not generate this filter when filter with
  unless _roomId or isDirectMessage
    if _storyId
      $stFilter = StoryModel.findOneAsync _id: _storyId, '_id members'
      .then (story) ->
        throw new Err('OBJECT_MISSING', "Story #{_storyId}") unless story
        hasMember = story._memberIds.some (_memberId) -> "#{_memberId}" is _sessionUserId
        throw new Err('MEMBER_CHECK_FAIL', "Story #{_storyId}") unless hasMember
        stFilter = term: _storyId: _storyId
    else
      $stFilter = StoryModel.find
        team: _teamId
        members: _sessionUserId
      , '_id'
      .sort _id: -1
      .limit 30
      .execAsync()
      .then (stories = []) ->
        _storyIds = stories.map (story) -> "#{story._id}"
        return unless _storyIds.length > 0
        stFilter = terms: _storyId: _storyIds

  # Get direct messages filter
  unless _roomId or _storyId
    # Do not read team members when look for room messages
    $_teamMemberIds = MemberModel.findAsync
      team: _teamId
    , '_id user'
    .map (member) -> member?._userId?.toString()

    $dmFilter = $_teamMemberIds.then (_userIds) ->
      youToOthers =
        bool:
          must: [
            term: _creatorId: _sessionUserId
          ,
            terms: _toId: _userIds
          ]
      othersToYou =
        bool:
          must: [
            term: _toId: _sessionUserId
          ,
            terms: _creatorId: _userIds
          ]
      dmFilter =
        bool:
          must: [
            missing: field: '_roomId'
          ,
            term: _teamId: _teamId
          ]
          should: [youToOthers, othersToYou]

  # =================== Start build query dsl and filters ===================

  $queryDsl = Promise.resolve({})

  # Combile filters
  if isDirectMessage  # Only use direct message filter
    $filter = $dmFilter
  else if _roomId  # Only use room message filter
    $filter = $rmFilter
  else if _storyId
    $filter = $stFilter
  else
    $filter = Promise.all([
      $rmFilter
      $dmFilter
      $stFilter
    ]).then ([
      rmFilter
      dmFilter
      stFilter
    ]) ->
      filter =
        bool:
          should: [rmFilter, dmFilter, stFilter].filter (filter) -> filter

  timeRange or= 'quarter'

  $queryDsl = $queryDsl.then (queryDsl) ->

    switch timeRange
      when 'day'
        startDate = moment().add(-1, 'day')
        currentDate = moment()
        if startDate.format('YYYYMM') is currentDate.format('YYYYMM')
          queryDsl.index = "talk_messages_" + currentDate.format('YYYYMM')
        else
          queryDsl.index = "talk_messages_#{startDate.format('YYYYMM')},talk_messages_#{currentDate.format('YYYYMM')}"
      when 'week'
        startDate = moment().add(-7, 'day')
        currentDate = moment()
        if startDate.format('YYYYMM') is currentDate.format('YYYYMM')
          queryDsl.index = "talk_messages_" + currentDate.format('YYYYMM')
        else
          queryDsl.index = "talk_messages_#{startDate.format('YYYYMM')},talk_messages_#{currentDate.format('YYYYMM')}"
      when 'month'
        startDate = moment().add(-1, 'month')
        currentDate = moment()
        if startDate.format('YYYYMM') is currentDate.format('YYYYMM')
          queryDsl.index = "talk_messages_" + currentDate.format('YYYYMM')
        else
          queryDsl.index = "talk_messages_#{startDate.format('YYYYMM')},talk_messages_#{currentDate.format('YYYYMM')}"
      when 'quarter'
        indexNames = [-3..0].map (offset) -> "talk_messages_#{moment().add(offset, 'month').format('YYYYMM')}"
        queryDsl.index = indexNames.join ','
      when 'year'
        indexNames = [-12..0].map (offset) -> "talk_messages_#{moment().add(offset, 'month').format('YYYYMM')}"
        queryDsl.index = indexNames.join ','
      else throw new Err('PARAMS_INVALID', 'timeRange')

    queryDsl

  $filter = $filter.then (filter) ->
    switch timeRange
      when "day" then tsFilter = range: createdAt: gte: "now/d"
      when "week" then tsFilter = range: createdAt: gte: "now-7d/d"
      when "month" then tsFilter = range: createdAt: gte: "now-1M/d"
      when "quarter" then tsFilter = range: createdAt: gte: "now-3M/d"
      when 'year' then return filter
      else throw new Err('PARAMS_INVALID', 'timeRange')

    _combileFilter filter, "must", tsFilter

  # Add tag id filter
  if _tagId
    $filter = $filter.then (filter) ->
      tagFilter = term: 'tags._tagId': _tagId
      _combileFilter filter, 'must', tagFilter
  else if hasTag
    $filter = $filter.then (filter) ->
      tagFilter = exists: field: 'tags._tagId'
      _combileFilter filter, 'must', tagFilter

  # Add creator filter on general filters
  if _creatorId
    $filter = $filter.then (filter) ->
      creatorFilter = term: _creatorId: _creatorId
      _combileFilter filter, 'must', creatorFilter

  else if _creatorIds
    $filter = $filter.then (filter) ->
      creatorFilter = terms: _creatorId: _creatorIds
      _combileFilter filter, 'must', creatorFilter

  # Add to filter on general filters
  if _toId
    $filter = $filter.then (filter) ->
      toFilter = term: _toId: _toId
      _combileFilter filter, 'must', toFilter

  else if _toIds
    $filter = $filter.then (filter) ->
      toFilter = terms: _toId: _toIds
      _combileFilter filter, 'must', toFilter

  # Build the query DSL
  $queryDsl = Promise.all [$queryDsl, $filter]
  .spread (queryDsl, filter) ->
    queryDsl.size = limit
    queryDsl.from = limit * (page - 1)
    queryDsl.highlight =
      fields:
        'body': {}
        'attachments.data.title': {}
        'attachments.data.text': {}
        'attachments.data.fileName': {}
    queryDsl.query =
      filtered:
        filter: filter
        query:
          query_string:
            fields: [
              'body'
              'attachments.data.title'
              'attachments.data.text'
              'attachments.data.fileName'
            ]
            query: keyword or '*'  # Search for all when the keyword is not defined
    queryDsl.sort = sort if sort
    queryDsl.sort = createdAt: order: 'desc' unless sort or keyword
    queryDsl

_typeDsls =
  general: _generalQueryDsl

  file: (req, res, callback) ->
    {fileCategory} = req.get()
    switch fileCategory
      when 'image' then fileCategories = ['image']
      when 'document' then fileCategories = ['text', 'pdf', 'message']
      when 'media' then fileCategories = ['audio', 'video']
      when 'other' then fileCategories = ['application', 'font']

    _typeDsls.general(req).then (queryDsl) ->
      {filter, query} = queryDsl.query.filtered
      # Generate file filter
      fileFilter =
        bool:
          must: [
            term: 'attachments.category': 'file'
          ]
      if fileCategories
        fileFilter.bool.must.push terms: 'attachments.data.fileCategory': fileCategories
      # Combine with general filter
      filter = _combileFilter filter, 'must', fileFilter
      queryDsl.query.filtered.filter = filter
      queryDsl.query.filtered.query.query_string.fields = ['attachments.data.fileName']  # Only search for the fileName
      queryDsl

  thirdapp: (req, res, callback) ->
    _typeDsls.general(req).then (queryDsl) ->
      {filter, query} = queryDsl.query.filtered
      appFilter =
        bool:
          must: [
            term: 'attachments.category': 'quote'
          ,
            term: 'attachments.data.category': 'thirdapp'
          ]
      filter = _combileFilter filter, 'must', appFilter
      queryDsl.query.filtered.filter = filter
      queryDsl.query.filtered.query.query_string.fields = ['body', 'attachments.data.title', 'attachments.data.text']
      queryDsl

  url: (req) ->
    _typeDsls.general(req).then (queryDsl) ->
      {filter, query} = queryDsl.query.filtered
      urlFilter =
        bool:
          must: [
            term: 'attachments.category': 'quote'
          ,
            term: 'attachments.data.category': 'url'
          ]
      filter = _combileFilter filter, 'must', urlFilter
      queryDsl.query.filtered.filter = filter
      queryDsl.query.filtered.query.query_string.fields = ['attachments.data.title', 'attachments.data.text']
      queryDsl

  rtf: (req) ->
    _typeDsls.general(req).then (queryDsl) ->
      {filter, query} = queryDsl.query.filtered
      rtfFilter =
        bool:
          must: [
            term: 'attachments.category': 'rtf'
          ]
      filter = _combileFilter filter, 'must', rtfFilter
      queryDsl.query.filtered.filter = filter
      queryDsl.query.filtered.query.query_string.fields = ['attachments.data.title', 'attachments.data.text']
      queryDsl

  snippet: (req) ->
    {codeType} = req.get()
    _typeDsls.general(req).then (queryDsl) ->
      {filter, query} = queryDsl.query.filtered
      snippetFilter =
        bool:
          must: [
            term: "attachments.category": "snippet"
          ]
      if codeType
        snippetFilter.bool.must.push term: "attachments.data.codeType": codeType
      filter = _combileFilter filter, 'must', snippetFilter
      queryDsl.query.filtered.filter = filter
      queryDsl.query.filtered.query.query_string.fields = ['attachments.data.title', 'attachments.data.text']
      queryDsl

  calendar: (req) ->
    _typeDsls.general(req).then (queryDsl) ->
      {filter, query} = queryDsl.query.filtered
      calendarFilter =
        bool:
          must: [
            term: 'attachments.category': 'calendar'
          ]
      filter = _combileFilter filter, 'must', calendarFilter
      queryDsl.query.filtered.filter = filter
      queryDsl.query.filtered.query.query_string.fields = ['body']
      queryDsl

  ###*
   * Only messages send from user to user
   * @param  {Request} req
   * @return {Promise} queryDsl
  ###
  message: (req) ->
    _typeDsls.general(req).then (queryDsl) ->
      queryDsl.query.filtered.query.query_string.fields = ['body']
      queryDsl

###*
 * Search for messages
 * @param  {Request} req
 * @param  {Response} res
 * @param  {Function} callback
 * @return {Promise} data - Response data
###
exports.search = (req, res, callback) ->
  {type} = req.get()
  type or= 'general'
  return callback(new Err('PARAMS_INVALID', "type #{type} is not defined")) unless _typeDsls[type]
  $queryDsl = _typeDsls[type] req

  $searchResult = $queryDsl.then (queryDsl) ->
    SearchMessageModel.searchAsync queryDsl.query, queryDsl
  .then (searchResult) ->
    throw new Err('SEARCH_FAILED') unless searchResult?.hits?.hits
    searchResult

  $resData = $searchResult.then (searchResult) ->
    resData =
      total: searchResult.hits.total
      messages: []
    _messageIds = searchResult.hits.hits.map (hit) -> hit._id
    messageHash = {}

    MessageModel.findByIdsAsync _messageIds

    .map (message) -> messageHash["#{message._id}"] = message.toJSON()

    .then ->
      resData.messages = searchResult.hits.hits.map (hit) ->
        return false unless messageHash[hit._id]
        message = messageHash[hit._id]
        message.highlight = hit.highlight
        message._score = hit._score
        message
      .filter (message) -> message

      resData

  $resData.nodeify callback
