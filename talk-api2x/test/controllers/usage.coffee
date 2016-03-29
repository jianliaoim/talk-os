should = require 'should'
Promise = require 'bluebird'
limbo = require 'limbo'

app = require '../app'
{prepare, cleanup, requestAsync} = app

describe 'Usage#CURD', ->

  before prepare

  it 'should read a full list of usages', (done) ->

    options =
      method: 'GET'
      url: '/usages'
      qs:
        _sessionUserId: app.user1._id
        _teamId: app.team1._id

    requestAsync options

    .spread (res) ->
      usages = res.body
      usages[0].type.should.eql 'userMessage'
      usages[1].type.should.eql 'inteMessage'
      usages[2].type.should.eql 'file'
      usages[3].type.should.eql 'call'
      usages.forEach (usage) -> usage.should.have.properties 'amount', 'maxAmount', 'team', 'type', 'month'

    .nodeify done

  it 'should update the usages when do something', (done) ->

    # Create a message
    $message = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _roomId: app.room1._id
          body: 'ok'
      requestAsync options

    $file = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _roomId: app.room1._id
          attachments: [
            category: 'file'
            data:
              "fileSize" : 86264,
              "fileCategory" : "image",
              "fileType" : "png",
              "imageWidth" : 1041,
              "fileName" : "屏幕快照 2016-02-01 下午2.43.25.png",
              "fileKey" : "110d5ed584332bf5da96fe96b95f8c681dbf",
              "imageHeight" : 437
          ]
      requestAsync options

    $usages = Promise.all [$message, $file]

    .delay(100).then ->
      options =
        method: 'GET'
        url: '/usages'
        qs:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id

      requestAsync(options).spread (res) -> res.body

    .then (usages) ->
      usages[0].amount.should.eql 2
      usages[1].amount.should.eql 0
      usages[2].amount.should.eql 86264

    .nodeify done

  after cleanup
