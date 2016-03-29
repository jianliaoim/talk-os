{Schema} = require 'mongoose'
Promise = require 'bluebird'

allowedDisplayModes = ['default', 'slim']

module.exports = PreferenceSchema = new Schema
  emailNotification: type: Boolean, default: true
  desktopNotification: type: Boolean, default: true
  _latestTeamId: Schema.Types.ObjectId
  _latestRoomId: Schema.Types.ObjectId
  hasShownTips: type: Boolean, default: false
  hasSentLoginMail: type: Boolean, default: false  # Send login mail with application download urls
  hasShownRichTextTips: type: Boolean, default: false
  notifyOnRelated: type: Boolean, default: false  # Only send notification when mention or direct message
  language: type: String, default: 'zh'
  displayMode: type: String, default: 'default', set: (mode) -> if mode in allowedDisplayModes then mode else 'default' # default|slim
  readNoticeAt: Date  # Get the latest notification time
  muteWhenWebOnline: type: Boolean, default: false
  customOptions:
    needTalkAIReply: type: Boolean, default: true
    hasGetReply: type: Boolean, default: false
  timezone: type: String, default: 'Asia/Shanghai'
  pushOnWorkTime: type: Boolean, default: false  # Push between 8:00 ~ 22:00
  webData: type: Object
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  read: 'secondaryPreferred'

PreferenceSchema.statics.updateByUserId = (_userId, update, callback = ->) ->
  @findOneAndSave
    _id: _userId
  , update
  , upsert: true
  , callback
