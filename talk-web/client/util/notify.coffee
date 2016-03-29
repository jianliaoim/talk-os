
if window.nwDispatcher?.requireNwGui
  nwGui = window.nwDispatcher.requireNwGui()
  nwWin = nwGui.Window.get()


format  = require './format'
time    = require './time'
typeUtil = require './type'

if typeof window isnt 'undefined'
  Favico = require 'favico.js'
  favicon = new Favico
    animation: 'none'

exports.desktop = (data, cb) ->
  data.body = data.body.replace /[\n\r]+/g, ' '
  if window.MacGap?
    window.MacGap.notify
      title: data.title
      content: data.body or ''
  else if window.macgap?
    window.macgap.growl.notify
      title: data.title
      content: data.body or ''
  else if window.Notification?
    message = new window.Notification data.title, data
    message.onclick = -> cb?()
    time.delay 3000, ->
      message.close()

exports.favicon = (number) ->
  return if typeof window is 'undefined'
  number = Number(number) unless typeUtil.isNumber(number)
  number = format.escape100 number
  if number is @oldNumber
    return
  @oldNumber = number

  if window.MacGap?
    window.MacGap.Dock.addBadge number
  else if window.macgap?
    window.macgap.dock.badge = number
  else if nwWin
    nwWin.setBadgeLabel number
  else if window.badge? # private API targeting Electron
    window.badge number
  else
    favicon.badge number
