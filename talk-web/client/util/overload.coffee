typeUtil = require '../util/type'
analytics = require '../util/analytics'

_open = window.open
window.open = (url) ->
  if window.MacGap?.Window
    window.MacGap.Window.open url: url
  else
    _open.apply window, arguments

if __DEV__
  installDevTools = require('immutable-devtools')
  installDevTools.default require('immutable')

if not __DEV__

  recorder = require 'actions-recorder'
  util = require './util'
  config = require '../config'
  reqwest = require '../util/reqwest'
  debounce = require 'debounce'

  count = 0
  window.onerror = debounce (message, source, lineno, colno, error) ->
    console.error arguments
    return if message.indexOf('Script error') >= 0
    return if message.indexOf('Minified exception occurred') >= 0
    return if message.indexOf('object XMLHttpRequest') >= 0

    count += 1
    return if count is 5

    text = [message, '\n', error?.stack].join('\n')
    text = util.withMachineInfo(text, recorder.getStore())

    reqwest
      url: config.windowOnErrorUrl
      method: 'POST'
      contentType: 'application/json'
      data: JSON.stringify
        title: message
        text: text

    return true

  , 5000, true

# 统计用户活跃度。每隔一个小时发一次数据
STORAGE_ACTIVE_KEY = 'jianliaoAlive'
lastSendTime =
  if typeUtil.isUndefined(window.localStorage)
    0
  else
    window.localStorage.getItem(STORAGE_ACTIVE_KEY) or 0
window.onclick = ->
  now = (new Date).valueOf()
  if now - lastSendTime >= 60 * 60 * 1000
    analytics.alive()
    lastSendTime = now
    if not typeUtil.isUndefined(window.localStorage)
      window.localStorage.setItem(STORAGE_ACTIVE_KEY, now)
