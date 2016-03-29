shortid = require 'shortid'
Immutable = require 'immutable'

isEqual = require 'lodash.isequal'
fieldsReader = require './fields-reader'

exports.mapFieldToDefaultMethod = (field) ->
  switch field
    when '_roomId' then @defaultRoomId
    when 'url' then @defaultUrl
    when 'token' then @defaultToken
    when 'events' then @defaultEvents
    when 'title' then @defaultTitle
    when 'description' then @defaultDescription
    when 'iconUrl' then @defaultIconUrl
    when 'webhookUrl' then @defaultWebhookUrl
    else throw new Error "map needs update"

exports.mapFieldToDefinedMethod = (field) ->
  switch field
    when '_roomId' then @definedRoomId
    when 'url' then @definedUrl
    when 'token' then @definedToken
    when 'events' then @definedEvents
    when 'title' then @definedTitle
    when 'description' then @definedDescription
    when 'iconUrl' then @definedIconUrl
    when 'webhookUrl' then @definedWebhookUrl
    else throw new Error "map needs update"

exports.mapFieldToUpdatedMethod = (field) ->
  switch field
    when '_roomId' then @updatedRoomId
    when 'url' then @updatedUrl
    when 'token' then @updatedToken
    when 'events' then @updatedEvents
    when 'title' then @updatedTitle
    when 'description' then @updatedDescription
    when 'iconUrl' then @updatedIconUrl
    when 'webhookUrl' then @updateWebhookUrl
    else throw new Error "map needs update"

# _roomId

exports.defaultRoomId = (inte, settings) ->
  inte?.get('_roomId') or settings._roomId

exports.definedRoomId = (_roomId) ->
  _roomId?

exports.updatedRoomId = (a, b) ->
  a isnt b

# url

exports.defaultUrl = (inte, settings) ->
  inte?.get('url') or undefined

exports.definedUrl = (url) ->
  url? and url.length > 0

exports.updatedUrl = (a, b) ->
  a isnt b

# token

exports.defaultToken = (inte, settings) ->
  if inte?
    return inte.get('token')
  # or maybe need to generate one
  tokenField = fieldsReader.getField settings.fields, 'token'
  if tokenField.autoGen
    shortid.generate()
  else
    undefined

exports.definedToken = (token) ->
  token?

exports.updatedToken = (a, b) ->
  a isnt b

# webhookUrl

exports.defaultWebhookUrl = (inte, settings) ->
  if inte?
    return inte.get('webhookUrl')

exports.definedWebhookUrl = (webhookUrl) ->
  webhookUrl?

exports.updateWebhookUrl = (a, b) ->
  a isnt b

# events

exports.defaultEvents = (inte, settings) ->
  inte?.get('events') or Immutable.List()

exports.definedEvents = (events) ->
  events.length > 0

exports.updatedEvents = (a, b) ->
  not (isEqual a, b)

# title

exports.defaultTitle = (inte, settings) ->
  inte?.get('title') or settings.title

exports.definedTitle = (title) ->
  title? and title.length > 0

exports.updatedTitle = (a, b) ->
  a isnt b

# description

exports.defaultDescription = (inte, settings) ->
  inte?.get('description') or undefined

exports.definedDescription = (description) ->
  # description is optional
  return true

exports.updatedDescription = (a, b) ->
  a isnt b

# iconUrl

exports.defaultIconUrl = (inte, settings) ->
  inte?.get('iconUrl') or settings.iconUrl

exports.definedIconUrl = (iconUrl) ->
  iconUrl? and iconUrl.length > 0

exports.updatedIconUrl = (a, b) ->
  a isnt b
