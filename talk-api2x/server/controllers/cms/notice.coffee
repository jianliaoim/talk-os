limbo = require 'limbo'

validator = require 'validator'
_ = require 'lodash'
app = require '../../server'

{NoticeModel} = limbo.use 'talk'

module.exports = noticeController = app.controller 'cms/notice', ->

  @ensure 'content', only: 'create'

  editableFields = [
    'content'
    'postAt'
  ]

  @action 'readOne', (req, res, callback) ->
    {_id} = req.get()
    NoticeModel.findOne _id: _id, callback

  @action 'read', (req, res, callback) ->
    {postAt, limit, page} = req.get()
    limit or= 30
    page or= 1
    if postAt is ''
      NoticeModel
      .find postAt: null
      .sort _id: -1
      .exec callback
    else
      query = NoticeModel.find(postAt: $ne: null)
      .sort postAt: -1
      query = query.limit(limit) if limit
      query = query.skip(limit * (page - 1)) if page
      query.exec callback

  @action 'create', (req, res, callback) ->
    {_sessionUserId, content, postAt} = req.get()
    notice = new NoticeModel
      creator: _sessionUserId
      content: content
    notice.postAt = if validator.isDate(postAt) then new Date(postAt)
    notice.save callback

  @action 'update', (req, res, callback) ->
    {_id} = req.get()
    update = _.pick(req.get(), editableFields)
    update.updatedAt = new Date
    NoticeModel.findOneAndSave _id: _id, update, callback

  @action 'remove', (req, res, callback) ->
    {_id} = req.get()
    NoticeModel.remove _id: _id, callback
