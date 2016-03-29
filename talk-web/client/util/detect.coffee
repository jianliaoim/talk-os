msgDsl = require 'talk-msg-dsl'
Immutable = require 'immutable'

dev = require './dev'
Util = require './util'
type = require '../util/type'
assemble = require '../util/assemble'

if typeof window isnt 'undefined'
  canvas = document.createElement 'canvas'
  ctx = canvas.getContext '2d'

exports.isSafariFullscreen = ->
  unless Util.parseUA().browser is 'safari'
    return false
  # screenTop is tricky, not supported in Firefox
  # returns 23 in Safari when not in fullscreen
  return window.screenTop is 0

exports.isTalkai = (data) ->
  if Immutable.Map.isMap(data)
    data.get('isRobot') and data.get('service') is 'talkai'
  else
    dev.warn "undefined data to detect talkai"
    dev.trace()
    false

exports.isRobot = (item) ->
  item.get('isRobot') and not exports.isTalkai(item)

exports.isPageFocused = ->
  if document.hasFocus?
  then document.hasFocus()
  else true

exports.isIPad = ->
  window.navigator.userAgent.match(/iPad/i)

exports.userInContent = (body, _userId) ->
  return if not body
  allMembers = assemble.allMembers()
  msgDsl.read(body)
    .filter type.isObject
    .some (obj) ->
      obj.category is 'at' and (obj.model is _userId or obj.model is allMembers._id)

exports.imageUrlInHtml = (html) ->
  match = html.match(/<img.*?[\'\"](http(s)?:\/\/[\x21-\x7F\*]+)[\'\"].*?\>/i)
  match?[1] or undefined

exports.mentionInContent = (content) ->
  msgDsl.read(content)
  .filter (item) -> type.isObject(item) and item.category is 'at'
  .map (item) -> item.model

exports.textWidthSmaller = (text, style, width, length) ->
  # length is used as a fallback solution
  if ctx.measureText?
    ctx.font = "#{style.fontSize}px #{style.fontFamily}"
    ctx.measureText(text).width < width
  else
    text.length < length

exports.isHtml = (string) ->
  /<[a-z][\s\S]*>/i.test(string)

exports.inChannel = (channel) ->
  return false unless channel?
  not channel.get 'isQuit'

exports.isImageWithPreview = (data) ->
  return false unless data?
  ImageTypesWithoutPreview = ['ico', 'psd']
  isImage = data.get('fileCategory') is 'image'
  hasCertainSize = data.get('imageHeight') and data.get('imageWidth')
  hasPreview = data.get('fileType') not in ImageTypesWithoutPreview
  isImage and hasCertainSize and hasPreview and data.get('thumbnailUrl')?

exports.isMessageFake = (message) ->
  return false unless message?
  isFake = message.get('_id').indexOf('fake') is 0
  isLocal = message.get('isLocal')
  isFake or isLocal
