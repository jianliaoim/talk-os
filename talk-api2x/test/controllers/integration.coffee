should = require 'should'
Promise = require 'bluebird'

limbo = require 'limbo'
serviceLoader = require 'talk-services'
config = require 'config'

serviceLoader.config.rss.serviceUrl = 'http://127.0.0.1:7632/rssspider'

app = require '../app'
{prepare, clear, request, requestAsync} = app

describe 'Integration', ->

  before prepare

  it 'should create an integration', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'integration:create'
            hits |= 0b1
            data.should.have.properties '_teamId', '_roomId', '_creatorId', 'title', 'hashId'
            data.category.should.eql 'rss'
            "#{data._teamId}".should.eql "#{app.team1._id}"
            "#{data._roomId}".should.eql "#{app.room1._id}"
            data.should.not.have.properties 'token'
            app.integration1 = data
          if event is 'message:create'
            hits |= 0b10
            data.body.should.containEql '{{__info-create-integration}} 小滴滴'
          resolve() if hits is 0b11
        catch err
          reject err

    $integration = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/integrations'
        body:
          _teamId: app.team1._id
          _roomId: app.room1._id
          token: 'abc'
          url: 'http://dev.talk.ai/feed'
          category: 'rss'
          title: '小滴滴'
          _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$broadcast, $integration]
    .nodeify done

  it 'should read the list of integrations', (done) ->

    $integrations = Promise.resolve().then ->
      options =
        method: 'GET'
        url: '/integrations'
        qs:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id

      requestAsync options

    .spread (res) ->
      res.body.length.should.eql 1
      res.body.forEach (integration) ->
        integration.category.should.eql 'rss'

    .nodeify done

  it 'should read one integration with token', (done) ->

    $integration = Promise.resolve().then ->
      options =
        method: 'GET'
        url: "/integrations/#{app.integration1._id}"
        qs:
          _sessionUserId: app.user1._id
      requestAsync options

    .spread (res) ->
      res.body.should.have.properties 'token'
      res.body.category.should.eql 'rss'

    .nodeify done

  it 'should read the list of integrations by app token', (done) ->

    $integrations = Promise.resolve().then ->
      options =
        method: 'GET'
        url: '/integrations/batchread'
        qs:
          appToken: config.serviceConfig.serviceTokens.rss
      requestAsync options

    .spread (res) ->
      res.body.length.should.eql 1
      res.body.forEach (integration) ->
        integration.should.have.properties 'token'
        integration.category.should.eql 'rss'

    .nodeify done

  it 'should set the error infomation of integration by app token', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'integration:update'
            hits |= 0b1
            data.errorInfo.should.eql 'Request timeout'
            data.should.not.have.properties 'token', 'refreshToken'
          if event is 'message:create' and data.body.indexOf('Request timeout') > -1
            hits |= 0b10
            data.should.have.properties 'body', 'team'
            "#{data._teamId}".should.eql "#{app.team1._id}"
            "#{data._toId}".should.eql "#{app.user1._id}"
          resolve() if hits is 0b11
        catch err
          reject err

    $integrations = Promise.resolve().then ->
      options =
        method: 'POST'
        url: "/integrations/#{app.integration1._id}/error"
        qs:
          appToken: config.serviceConfig.serviceTokens.rss
          errorInfo: 'Request timeout'
      requestAsync options

    .spread (res) ->
      res.body.errorInfo.should.eql 'Request timeout'

    Promise.all [$broadcast, $integrations]
    .nodeify done

  it 'should update an integartion', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'integration:update'
            hits |= 0b1
            data.title.should.eql '大滴滴'
            app.integration1 = data
          if event is 'message:create' and data.body.indexOf('{{__info-update-integration}} 大滴滴') > -1
            hits |= 0b10
          resolve() if hits is 0b11
        catch err
          reject err

    $integration = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/integrations/#{app.integration1._id}"
        body:
          _roomId: app.room2._id
          title: '大滴滴'
          _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$broadcast, $integration]
    .nodeify done

  it 'should remove an integration', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'integration:remove'
            hits |= 0b1
            data.should.not.have.properties 'token'
            data.should.have.properties '_roomId', '_teamId'
          if event is 'message:create' and data.body.indexOf('{{__info-remove-integration}} 大滴滴') > -1
            hits |= 0b10
          resolve() if hits is 0b11
        catch err
          reject err

    $integration = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "/integrations/#{app.integration1._id}"
        body:
          _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$broadcast, $integration]
    .nodeify done

  after clear
