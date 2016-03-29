should = require 'should'
Promise = require 'bluebird'
limbo = require 'limbo'
serviceLoader = require 'talk-services'

app = require '../app'
{prepare, cleanup, request, requestAsync} = app

describe 'Service#Outgoing', ->

  before prepare

  it 'should send message to robot', (done) ->

    $service = serviceLoader.load 'outgoing'

    $broadcast = $service.then (service) ->
      new Promise (resolve, reject) ->
        hits = 0
        app.broadcast = (channel, event, data) ->
          try
            if event is 'message:create' and "#{data._creatorId}" is "#{service.robot._id}"
              hits |= 0b1
              data.body.should.eql 'ok'
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
          category: 'outgoing'
          url: 'http://localhost:7632/outgoing/messages'
      requestAsync(options)

    $message = $integration.then (integration) ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _roomId: app.room1._id
          _teamId: app.team1._id
          body: 'Hello'
      requestAsync options

    Promise.all [$broadcast, $integration, $message]
    .nodeify done

  after cleanup
