
exports.postSave = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _channelId = actionData.get('_channelId')
  postData = actionData.get('post')

  dataPath = "#{_teamId}+#{_channelId}"
  store.setIn ['drafts', 'post', dataPath], postData

exports.postDelete = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _channelId = actionData.get('_channelId')

  dataPath = "#{_teamId}+#{_channelId}"
  store.deleteIn ['drafts', 'post', dataPath]

exports.draftSave = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _channelId = actionData.get('_channelId')
  draftData = actionData.get('draft')

  dataPath = "#{_teamId}+#{_channelId}"
  store.setIn ['drafts', 'draft', dataPath], draftData

exports.draftDelete = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _channelId = actionData.get('_channelId')

  dataPath = "#{_teamId}+#{_channelId}"
  store.deleteIn ['drafts', 'draft', dataPath]

exports.snippetSave = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _channelId = actionData.get('_channelId')
  snippetData = actionData.get('snippet')

  dataPath = "#{_teamId}+#{_channelId}"
  store.setIn ['drafts', 'snippet', dataPath], snippetData

exports.snippetDelete = (store, actionData) ->
  _teamId = actionData.get('_teamId')
  _channelId = actionData.get('_channelId')

  dataPath = "#{_teamId}+#{_channelId}"
  store.deleteIn ['drafts', 'snippet', dataPath]

exports.deleteStoryDraft = (store, draftData) ->
  _teamId = draftData.get '_teamId'
  category = draftData.get 'category'

  store.deleteIn [ 'drafts', 'story', _teamId, category ]

exports.deleteAllStoryDraft = (store, draftData) ->
  _teamId = draftData.get '_teamId'

  store.deleteIn [ 'drafts', 'story', _teamId ]

exports.updateStoryDraft = (store, draftData) ->
  _teamId = draftData.get '_teamId'
  data = draftData.get 'data'
  category = draftData.get 'category'

  key = data.get('key')
  value = data.get('value')
  store.setIn [ 'drafts', 'story', _teamId, category, key ], value

exports.toggleMarkdown = (store, status) ->
  store.setIn [ 'drafts', 'activeMarkdown' ], status
