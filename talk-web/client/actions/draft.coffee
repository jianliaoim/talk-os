dispatcher = require '../dispatcher'

exports.saveDraft = (_teamId, _channelId, draft) ->
  dispatcher.handleViewAction
    type: 'draft/draft-save'
    data:
      _teamId: _teamId
      _channelId: _channelId
      draft: draft

exports.clearDraft = (_teamId, _channelId) ->
  dispatcher.handleViewAction
    type: 'draft/draft-delete'
    data:
      _teamId: _teamId
      _channelId: _channelId

exports.savePost = (_teamId, _channelId, post) ->
  dispatcher.handleViewAction
    type: 'draft/post-save'
    data:
      _teamId: _teamId
      _channelId: _channelId
      post: post

exports.clearPost = (_teamId, _channelId) ->
  dispatcher.handleViewAction
    type: 'draft/post-delete'
    data:
      _teamId: _teamId
      _channelId: _channelId

exports.saveSnippet = (_teamId, _channelId, snippet) ->
  dispatcher.handleViewAction
    type: 'draft/snippet-save'
    data:
      _teamId: _teamId
      _channelId: _channelId
      snippet: snippet

exports.clearSnippet = (_teamId, _channelId) ->
  dispatcher.handleViewAction
    type: 'draft/snippet-delete'
    data:
      _teamId: _teamId
      _channelId: _channelId

exports.updateStoryDraft = (_teamId, storyCategory, storyData) ->
  dispatcher.handleViewAction
    type: 'draft/story/update'
    data:
      _teamId: _teamId
      data: storyData
      category: storyCategory

exports.deleteStoryDraft = (_teamId, storyCategory) ->
  dispatcher.handleViewAction
    type: 'draft/story/delete'
    data:
      _teamId: _teamId
      category: storyCategory

exports.deleteAllStoryDraft = (_teamId) ->
  dispatcher.handleViewAction
    type: 'draft/story/delete-all'
    data:
      _teamId: _teamId

exports.toggleMarkdown = (status) ->
  dispatcher.handleViewAction
    type: 'draft/toggle-markdown'
    data: status
