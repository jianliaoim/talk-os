Store = require 'store2'
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

# 统计用户活跃度。每隔一个小时发一次数据
STORAGE_ACTIVE_KEY = 'jianliaoAlive'
lastSendTime =
  Store.get(STORAGE_ACTIVE_KEY) or 0

window.onclick = ->
  now = (new Date).valueOf()
  if now - lastSendTime >= 60 * 60 * 1000
    analytics.alive()
    lastSendTime = now
    Store.set(STORAGE_ACTIVE_KEY, now)
