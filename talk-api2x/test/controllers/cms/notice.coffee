should = require 'should'
async = require 'async'
limbo = require 'limbo'
db = limbo.use 'talk'
{NoticeModel} = db
app = require '../../app'
{prepare, clear, request} = app

_createNotice = (callback) ->
  options =
    method: 'post'
    url: 'cms/notices'
    body: JSON.stringify
      _sessionUserId: app.user1._id
      content: 'One'
      postAt: new Date
  request options, callback

describe 'cms/notice#create', ->

  before prepare

  it 'should create a notice object', (done) ->

    _createNotice (err, res, notice) ->
      notice.should.have.properties 'content', 'postAt'
      done err

  after clear

describe 'cms/notice#update', ->

  before (done) ->
    async.auto
      prepare: prepare
      createNotice: ['prepare', (callback) ->
        _createNotice (err, res, notice) ->
          app.notice = notice
          callback err
      ]
    , done

  it 'should update a notice object', (done) ->

    postAt = new Date

    options =
      method: 'put'
      url: 'cms/notices/' + app.notice._id
      body: JSON.stringify
        _sessionUserId: app.user1._id
        content: 'Two'
    request options, (err, res, notice) ->
      notice.content.should.eql 'Two'
      done err

  after clear
