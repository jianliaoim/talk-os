Immutable = require 'immutable'

assemble = require '../util/assemble'

exports.create = (store, newStoryData) ->
  _teamId = newStoryData.get '_teamId'
  _storyId = newStoryData.get '_id'

  inCollection = (story) -> story.get('_id') is _storyId

  if store.hasIn(['stories', _teamId])
    store.updateIn ['stories', _teamId], (stories) ->
      if stories.some(inCollection)
        stories.map (story) ->
          if story.get('_id') is _storyId
            story.merge newStoryData
      else
        stories.unshift newStoryData
  else
    store

exports.leave = (store, storyData) ->
  _teamId = storyData.get '_teamId'
  _storyId = storyData.get '_id'

  if store.hasIn ['stories', _teamId]
    store.updateIn ['stories', _teamId], (stories) ->
      stories.map (story) ->
        if story.get('_id') is _storyId
          story.merge storyData
        else story
  else store

exports.join = (store, data) ->
  store

exports.read = (store, storyData) ->
  _teamId = storyData.get '_teamId'
  newStories = storyData.get 'data'

  if store.hasIn ['stories', _teamId]
    store.updateIn ['stories', _teamId], (existStories) ->
      newStories.forEach (newStory) ->
        storyIndex = existStories.findIndex (existStory) ->
          existStory.get('_id') is newStory.get('_id')

        if storyIndex >= 0
          existStories = existStories.set storyIndex, newStory
        else
          existStories = existStories.push newStory
      existStories
  else
    store.setIn ['stories', _teamId], newStories

exports.readone = (store, storyDatum) ->
  _teamId = storyDatum.get '_teamId'
  _targetId = storyDatum.get '_id'

  inCollection = (item) -> item.get('_id') is _targetId

  if store.hasIn ['stories', _teamId]
    store.updateIn ['stories', _teamId], (stories) ->
      if stories.some inCollection
        stories.map (story) ->
          if story.get('_id') is _targetId
            story.merge storyDatum
          else story
      else
        stories.push storyDatum
  else
    store.setIn ['stories', _teamId], Immutable.List([ storyDatum ])

exports.remove = (store, storyDatum) ->
  _teamId = storyDatum.get '_teamId'
  _storyId = storyDatum.get '_id'

  store
  .update 'stories', (cursor) ->
    if cursor.has _teamId
      cursor.update _teamId, (stories) ->
        stories.filterNot (story) -> story.get('_id') is _storyId
    else cursor

exports.update = (store, storyDatum) ->
  _teamId = storyDatum.get '_teamId'
  _storyId = storyDatum.get '_id'

  if store.hasIn ['stories', _teamId]
    store.updateIn ['stories', _teamId], (stories) ->
      stories.map (story) ->
        if story.get('_id') is _storyId
          story.merge storyDatum
        else story
  else store

# Dispatch from 'story/create-draft' with draft data,
# this func will set a draft story into store in 'drafts -> stories -> _id'
#
# @param { Immutable.Map } store
# @param { Immutable.Map } draftStoryData
#
# @return null

exports.createDraft = (store, draftStoryData) ->
  _id = draftStoryData.get '_id'
  _teamId = draftStoryData.get '_teamId'
  category = draftStoryData.get 'category'

  store.setIn [ 'drafts', 'stories', _id ], assemble.draftStory _teamId, _id, category
