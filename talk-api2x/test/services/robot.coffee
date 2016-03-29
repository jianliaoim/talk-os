should = require 'should'
Promise = require 'bluebird'
limbo = require 'limbo'

serviceLoader = require 'talk-services'
$service = serviceLoader.load 'robot'

app = require '../app'
{prepare, cleanup, request, requestAsync} = app

{
  UserModel
  RoomModel
} = limbo.use 'talk'

describe 'Service#Robot', ->

  before prepare

  it 'should create new team member when create new robot', (done) ->

    $broadcast = $service.then (robot) ->
      hits = 0
      new Promise (resolve, reject) ->
        app.broadcast = (channel, event, data) ->
          try
            if event is 'team:join'
              hits |= 0b1
              channel.should.eql "team:#{app.team1._id}"
              data.should.have.properties 'name', 'team', '_teamId'
              data.name.should.eql robot.title
              data.avatarUrl.should.eql robot.iconUrl
              data.isRobot.should.eql true
            resolve() if hits is 0b1
          catch err
            reject err

    $createIntegration = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/integrations'
        body:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
          category: 'robot'
          url: 'http://localhost:7632/outgoing/messages'
      requestAsync(options).spread (res) ->
        res.body.should.have.properties '_teamId', '_creatorId', 'robot'
        app.integration1 = res.body

    Promise.all [$broadcast, $createIntegration]
    .nodeify done

  it 'should update the robot when updating integration', (done) ->

    $updateIntegration = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/integrations/#{app.integration1._id}"
        body:
          _sessionUserId: app.user1._id
          title: '滴滴'
          description: '睡觉啦'
          iconUrl: "http://www.newicon.com"
      requestAsync(options).spread (res) ->
        res.body.should.have.properties '_teamId', "_creatorId", 'robot'
        res.body

    $robot = $updateIntegration.then (integration) ->
      UserModel.findOneAsync _id: integration._robotId
    .then (robot) ->
      app.robot1 = robot
      robot.name.should.eql '滴滴'
      robot.description.should.eql '睡觉啦'
      robot.avatarUrl.should.eql 'http://www.newicon.com'

    Promise.all [$updateIntegration, $robot]
    .nodeify done

  it 'should send message to robots', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'message:create' and "#{data._toId}" is "#{app.user1._id}"
            hits |= 0b1
            "#{data._creatorId}".should.eql "#{app.robot1._id}"
            data.body.should.eql 'ok'
            data.authorName.should.eql '小艾'
          resolve() if hits is 0b1
        catch err
          reject err

    $message = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _toId: app.robot1._id
          _teamId: app.team1._id
          body: 'Hello'
      requestAsync options

    Promise.all [$broadcast, $message]
    .nodeify done

  it 'should create a message to user1 when receive a webhook', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'message:create' and data.body is 'ok from webhook'
            hits |= 0b1
            "#{data._teamId}".should.eql "#{app.team1._id}"
            data.should.not.have.properties '_roomId'
            "#{data._creatorId}".should.eql "#{app.robot1._id}"
            data.attachments[0].data.text.should.eql "Hello"
          resolve() if hits is 0b1
        catch err
          reject err

    $webhook = Promise.resolve().then ->
      options =
        method: 'POST'
        url: "/services/webhook/#{app.integration1.hashId}"
        body:
          _toId: app.user1._id
          content: 'ok from webhook'
          text: 'Hello'
      requestAsync options

    Promise.all [$broadcast, $webhook]
    .nodeify done

  it 'should create a message to room1 when receive a webhook', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'message:create' and "#{data._roomId}" is "#{app.room1._id}"
            hits |= 0b1
            "#{data._teamId}".should.eql "#{app.team1._id}"
            data.should.not.have.properties '_toId'
            data.body.should.eql "ok"
            data.attachments[0].data.text.should.eql "Hello"
          resolve() if hits is 0b1
        catch err
          reject err

    $addMember = RoomModel.addMemberAsync app.room1._id, app.robot1._id

    $webhook = $addMember.then ->
      options =
        method: 'POST'
        url: "/services/webhook/#{app.integration1.hashId}"
        body:
          _roomId: app.room1._id
          content: 'ok'
          text: 'Hello'
      requestAsync options

    Promise.all [$broadcast, $webhook]
    .nodeify done

  it 'should receive new message when mention the robot in room', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          # Reply from robot
          if event is 'message:create' and "#{data._creatorId}" is "#{app.robot1._id}"
            hits |= 0b1
            "#{data._roomId}".should.eql "#{app.room1._id}"
            data.should.not.have.properties '_toId', '_storyId'
            data.body.should.eql "ok"
          resolve() if hits is 0b1
        catch err
          reject err

    $message = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _roomId: app.room1._id
          body: "hello <$at|#{app.robot1._id}|@robot$>"
      requestAsync options

    Promise.all [$broadcast, $message]
    .nodeify done

  it 'should remove the robot member when remove integration', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'team:leave'
            hits |= 0b1
            "#{data._teamId}".should.eql "#{app.team1._id}"
            "#{data._userId}".should.eql "#{app.robot1._id}"
          resolve() if hits is 0b1
        catch err
          reject err

    $removeIntegration = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "/integrations/#{app.integration1._id}"
        body:
          _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$broadcast, $removeIntegration]
    .nodeify done

  after cleanup
