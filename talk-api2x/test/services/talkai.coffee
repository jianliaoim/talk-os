should = require 'should'
Promise = require 'bluebird'
limbo = require 'limbo'
serviceLoader = require 'talk-services'

app = require '../app'
{prepare, cleanup, request, requestAsync} = app

{
  PreferenceModel
} = limbo.use 'talk'

describe 'Service#Talkai', ->

  before prepare

  it 'should send message to talkai', (done) ->

    $service = serviceLoader.load 'talkai'
    .then (service) ->
      service.config.url = 'http://localhost:7632/talkai'
      service

    $preference = Promise.resolve().then ->
      preference = new PreferenceModel _id: app.user1._id
      preference.$save()

    $broadcast = $service.then (service) ->
      new Promise (resolve, reject) ->
        hits = 0
        app.broadcast = (channel, event, data) ->
          try
            if event is 'message:create' and "#{data._creatorId}" is "#{service.robot._id}"
              hits |= 0b1
              data.body.should.eql 'Hello'
              "#{data._toId}".should.eql "#{app.user1._id}"
            resolve() if hits is 0b1
          catch err
            reject err

    $message = Promise.all [$service, $preference]
    .spread (service) ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
          _toId: service.robot._id
          body: '你好'
      requestAsync options

    Promise.all [$broadcast, $message]
    .nodeify done

  after cleanup
