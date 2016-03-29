apn = require 'apn'
config = require 'config'

apnConnection = new apn.Connection config.apn

pusher = module.exports

pusher.push = (token, alert, badge, payload = {}) ->
  myDevice = new apn.Device token
  note = new apn.Notification()
  note.expiry = Math.floor(Date.now() / 1000) + 3600
  note.badge = badge
  note.alert = alert
  note.sound = 'bubble.wav'
  note.category = 'COMMENT_CATEGORY'
  note.payload = payload
  apnConnection.pushNotification note, myDevice
