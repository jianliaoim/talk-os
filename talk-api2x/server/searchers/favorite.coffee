Promise = require 'bluebird'
_ = require 'lodash'
Err = require 'err1st'
util = require '../util'
{limbo} = require '../components'

{
  FavoriteModel
  SearchFavoriteModel
} = limbo.use 'talk'

_combileFilter = (filter, clause, children) ->
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
    _storyId
    type
    sort
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

  # Need team scope
  $filter = Promise.resolve
    bool:
      must: [
        term: _teamId: _teamId
      ,
        term: _favoritedById: _sessionUserId
      ]

  if isDirectMessage  # Filter only direct message
    $filter = $filter.then (filter) -> _combileFilter filter, 'must', exists: field: '_toId'
  else if _roomId  # Filter by room id
    $filter = $filter.then (filter) -> _combileFilter filter, 'must', term: _roomId: _roomId
  else if _storyId
    $filter = $filter.then (filter) -> _combileFilter filter, 'must', term: _storyId: _storyId

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
  $queryDsl = $filter.then (filter) ->
    queryDsl =
      size: limit
      from: limit * (page - 1)
      highlight:
        fields:
          'body': {}
          'attachments.data.title': {}
          'attachments.data.text': {}
          'attachments.data.fileName': {}
      query:
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
    SearchFavoriteModel.searchAsync queryDsl.query, queryDsl
  .then (searchResult) ->
    throw new Err('SEARCH_FAILED') unless searchResult?.hits?.hits
    searchResult

  $resData = $searchResult.then (searchResult) ->
    resData =
      total: searchResult.hits.total
      favorites: []
    _favoriteIds = searchResult.hits.hits.map (hit) -> hit._id
    favoriteHash = {}

    Promise.resolve()
    .then -> FavoriteModel.findByIdsAsync _favoriteIds
    .map (favorite) -> favoriteHash["#{favorite._id}"] = favorite.toJSON()
    .then ->
      resData.favorites = searchResult.hits.hits.map (hit) ->
        return false unless favoriteHash[hit._id]
        favorite = favoriteHash[hit._id]
        favorite.highlight = hit.highlight
        favorite._score = hit._score
        favorite
      .filter (favorite) -> favorite
      resData

  $resData.nodeify callback
