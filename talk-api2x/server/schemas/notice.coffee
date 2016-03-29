{Schema} = require 'mongoose'
Promise = require 'bluebird'
serviceLoader = require 'talk-services'

module.exports = NoticeSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  content: String
  postAt: Date  # Send after this time
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  read: 'secondaryPreferred'

NoticeSchema.statics.findMyUnreadNotices = (_userId, callback) ->
  PreferenceModel = @model 'Preference'
  NoticeModel = this

  PreferenceModel.findOneAsync _id: _userId, 'readNoticeAt'

  .then (preference = {}) ->

    {readNoticeAt} = preference

    unless readNoticeAt and (Date.now() - readNoticeAt) < 86400000 * 3
      readNoticeAt = Date.now() - 86400000 * 3

    NoticeModel.find postAt: $gt: readNoticeAt, $lt: Date.now()
    .sort postAt: -1
    .exec()

  .then (notices) -> callback null, notices

  .then null, callback

NoticeSchema.statics.checkForNewNotice = (_userId, _teamId, callback = ->) ->

  NoticeModel = this
  MessageModel = @model 'Message'
  PreferenceModel = @model 'Preference'

  $talkai = serviceLoader.getRobotOf 'talkai'
  $notices = NoticeModel.findMyUnreadNoticesAsync _userId

  Promise.all [$talkai, $notices]

  .spread (talkai, notices = []) ->
    lastNotice = notices[0]
    # Upgrade user read timestamp
    if lastNotice
      PreferenceModel.updateByUserId _userId, readNoticeAt: lastNotice.postAt

    notices.sort -> 1

    Promise.map notices, (notice) ->
      # Create message
      message = new MessageModel
        creator: talkai._id
        to: _userId
        team: _teamId
        body: notice.content
      message.$save()

  .nodeify callback
