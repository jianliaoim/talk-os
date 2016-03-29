should = require 'should'
fs = require 'fs'
path = require 'path'
async = require 'async'
Promise = require 'bluebird'
limbo = require 'limbo'
app = require '../app'
{prepare, cleanup, request, _app, requestAsync} = app
supertest = require 'supertest'
urlLib = require 'url'
serviceLoader = require 'talk-services'
qs = require 'querystring'
config = require 'config'

{
  IntegrationModel
} = limbo.use 'talk'

describe 'Service#Mailgun', ->

  @timeout 10000

  mailgun = require './mailgun.json'

  before prepare

  it 'should receive the mail body from mailgun and create new page', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'message:create'
            data._roomId.should.eql app.room1._id
            data.authorName.should.eql '许晶鑫'
            data.attachments.length.should.eql 1
            data.attachments[0].category.should.eql 'quote'
            quote = data.attachments[0].data
            quote.should.have.properties 'title', 'text'
            callback()
      mailgun: (callback) ->
        mailgun.recipient = app.room1.email
        options =
          method: 'post'
          url: 'services/mailgun'
          body: JSON.stringify mailgun
        request options, callback
    , done

  it 'should receive an email with attachment and create a message with files', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'message:create'
            # Do not save thumbnail pic in files
            data.attachments.length.should.eql 2
            data.attachments[0].category.should.eql 'quote'
            data.attachments[1].category.should.eql 'file'
            quote = data.attachments[0].data
            quote.text.should.containEql 'striker'  # The striker thumbnail url
            file1 = data.attachments[1].data
            file1.fileName.should.eql 'page.html'
            callback()
      mailgun: (callback) ->
        mailgun.recipient = app.room1.email
        req = supertest(_app).post('/' + path.join(config.apiVersion, 'services/mailgun'))
        Object.keys(mailgun).forEach (key) -> req.field key, mailgun[key] if toString.call(mailgun[key]) is '[object String]'
        req.attach 'document', __dirname + "/../files/page.html"
        req.attach 'document', __dirname + "/../files/thumbnail.jpg"
        req.end (err, res) -> callback err
    , done

  after cleanup

describe 'Service#ToApp', ->

  before prepare

  msgToken = ''

  it 'should generate an appToken and redirect to the app url', (done) ->
    async.auto
      toApp: (callback) ->
        options =
          method: 'get'
          url: '/services/toapp'
          qs:
            _sessionUserId: app.user1._id
            _teamId: app.team1._id
            _toId: app.user2._id
            url: 'http://somewhere.com'
        app.request options, (err, res) ->
          res.statusCode.should.eql 302
          appUrl = res.headers.location
          appUrl.should.containEql 'http://somewhere.com'
          appUrl.should.containEql 'msgToken'
          {msgToken, userName} = qs.parse(urlLib.parse(appUrl).query)
          userName.should.eql app.user1.name
          callback err
    , done

  it 'should send message by msgToken', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (channel, event, data, socketId) ->
          if event is 'message:create'
            hits |= 0b1
            data._creatorId.should.eql app.user1._id
            data._toId.should.eql app.user2._id
            data._teamId.should.eql app.team1._id
            quote = data.attachments[0].data
            quote.title.should.eql 'hello'
            quote.category.should.eql 'thirdapp'
          if event is 'notification:update'
            hits |= 0b10
            data.text.should.containEql 'hello'
          callback() if hits is 0b11
      createMessage: (callback) ->
        options =
          method: 'post'
          url: '/services/message'
          body: JSON.stringify
            msgToken: msgToken
            attachments: [
              category: 'quote'
              data: title: 'hello'
            ]
        app.request options, callback
    , done

  after cleanup

describe 'Service#Webhook', ->

  before prepare

  it 'should receive webhook and route messages to service', (done) ->

    $service = serviceLoader.load 'incoming'

    $broadcast = $service.then (service) ->
      new Promise (resolve, reject) ->
        hits = 0
        app.broadcast = (channel, event, data) ->
          try
            if event is 'message:create' and "#{data._creatorId}" is "#{service.robot._id}"
              hits |= 0b1
              data.body.should.eql 'Hello'
              data.authorName.should.eql '小艾'
            resolve() if hits is 0b1
          catch err
            reject err

    $integration = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/integrations'
        body:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
          _roomId: app.room1._id
          category: 'incoming'
      requestAsync options
      .spread (res) ->  app.integration1 = res.body

    $message = $integration.then (integration) ->
      options =
        method: 'POST'
        url: "/services/webhook/#{integration.hashId}"
        body:
          content: 'Hello'
          authorName: '小艾'
      requestAsync options

    Promise.all [$broadcast, $integration, $message]
    .nodeify done

  it 'should send error webhooks and receive an error infomation when errorTimes above 5', (done) ->

    $sendMsg = Promise.each [0..6], (n) ->
      # Without title or text
      options =
        method: 'POST'
        url: "/services/webhook/#{app.integration1.hashId}"
        body: authorName: '小艾'
      requestAsync options
      .catch (err) -> err.message.should.containEql 'Title and text can not be empty'

    $checkIntegration = $sendMsg.then ->
      IntegrationModel.findOneAsync _id: app.integration1._id
    .then (integration) ->
      integration.should.have.properties 'errorInfo', 'errorTimes'
      integration.errorTimes.should.eql 6

    $checkIntegration.nodeify done

  after cleanup
