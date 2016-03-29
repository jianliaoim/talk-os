Promise = require 'bluebird'
Err = require 'err1st'

limbo = require 'limbo'

{
  StoryModel
  SearchStoryModel
} = limbo.use 'talk'

_buildQuery = (req) ->
  {
    _teamId
    keyword
    category
    sort
    _sessionUserId
    limit
    page
    _creatorId
    _creatorIds
    fileCategory
  } = req.get()

  limit or= 10
  page = parseInt page
  page or= 1

  keyword = keyword?.trim()
  keyword = keyword[..20] if keyword?.length > 20

  return Promise.reject(new Err('PARAMS_MISSING', '_teamId keyword')) unless _teamId and keyword

  $filter = Promise.resolve().then ->
    bool:
      must: [
        term: _teamId: _teamId
      ,
        term: _memberIds: _sessionUserId
      ]

  if _creatorId
    $filter = $filter.then (filter) ->
      filter.bool.must.push term: _creatorId: _creatorId
      filter

  else if _creatorIds
    $filter = $filter.then (filter) ->
      filter.bool.must.push terms: _creatorId: _creatorIds
      filter

  if category
    $filter = $filter.then (filter) ->
      filter.bool.must.push term: category: category
      filter

  switch fileCategory
    when 'image' then fileCategories = ['image']
    when 'document' then fileCategories = ['text', 'pdf', 'message']
    when 'media' then fileCategories = ['audio', 'video']
    when 'other' then fileCategories = ['application', 'font']

  if fileCategories
    $filter = $filter.then (filter) ->
      filter.bool.must.push term: category: 'file'
      filter.bool.must.push terms: 'data.fileCategory': fileCategories
      filter

  $query = $filter.then (filter) ->
    query =
      size: limit
      from: limit * (page - 1)
      highlight:
        fields:
          'data.url': {}
          'data.title': {}
          'data.text': {}
          'data.fileName': {}
      query:
        filtered:
          filter: filter
          query:
            query_string:
              fields: [
                'data.url'
                'data.title'
                'data.text'
                'data.fileName'
              ]
              query: keyword
    query.sort = sort if sort
    query

exports.search = (req, res, callback) ->
  $query = _buildQuery req

  $result = $query.then (query) ->
    SearchStoryModel.searchAsync query.query, query

  .then (result) ->
    throw new Err('SEARCH_FAILED') unless result?.hits?.hits
    result

  $total = $result.then (result) -> result.hits.total

  $stories = $result.then (result) ->
    _storyIds = result.hits.hits.map (hit) -> hit._id
    storyMap = {}

    StoryModel.findByIdsAsync _storyIds

    .map (story) ->
      storyMap["#{story._id}"] = story.toJSON()

    .then ->
      stories = result.hits.hits.map (hit) ->
        return false unless storyMap[hit._id]
        story = storyMap[hit._id]
        story.highlight = hit.highlight
        story._score = hit._score
        story

      .filter (story) -> story

  Promise.props
    total: $total
    stories: $stories

  .nodeify callback


