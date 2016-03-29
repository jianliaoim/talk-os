should = require 'should'
Err = require 'err1st'
Promise = require 'bluebird'
limbo = require 'limbo'

app = require '../app'
{prepare, prepareAsync, cleanup} = app

{
  NotificationModel
  MessageModel
} = limbo.use 'talk'

_createMessages = ->
  # Message to user2
  $message1 = Promise.resolve().then ->
    message = new MessageModel
      team: app.team1._id
      creator: app.user1._id
      to: app.user2._id
      body: 'direct message'
    message.$save()
  # Message to room1
  $message2 = Promise.resolve().then ->
    message = new MessageModel
      team: app.team1._id
      creator: app.user1._id
      room: app.room1._id
      body: 'room message'
    message.$save()

  $broadcast = new Promise (resolve) ->
    num = 0
    # Wait for two notifications
    app.broadcast = (channel, event, data) ->
      if event is 'notification:update' and "#{data._userId}" is "#{app.user2._id}"
        num += 1
        resolve() if num is 2

  Promise.all [$message1, $message2, $broadcast]

describe 'Notification#CURD', ->

  before (done) ->
    $prepare = prepareAsync()

    $prepare.then _createMessages

    .nodeify done

  it 'should read the latest notifications', (done) ->

    options =
      method: 'GET'
      url: '/notifications'
      qs:
        _teamId: app.team1._id
        _sessionUserId: app.user2._id

    app.request options, (err, res, notifications) ->

      notifications.length.should.eql 2

      hits = 0

      notifications.forEach (notification) ->
        "#{notification.creator._id}".should.eql "#{app.user1._id}"
        "#{notification._userId}".should.eql "#{app.user2._id}"
        notification.unreadNum.should.eql 1
        if notification.type is 'dms'
          hits |= 0b1
          "#{notification.target._id}".should.eql "#{app.user1._id}"
        else if notification.type is 'room'
          hits |= 0b10
          "#{notification.target._id}".should.eql "#{app.room1._id}"

      app.notification1 = notifications[0]

      hits.should.eql 0b11

      done err

  it 'should update the notification', (done) ->

    options =
      method: 'PUT'
      url: "/notifications/#{app.notification1._id}"
      body:
        isPinned: true
        _sessionUserId: app.user2._id
        unreadNum: 0

    app.request options, (err, res, notification) ->
      notification.should.have.properties 'pinnedAt', 'isPinned', 'oldUnreadNum'
      notification.oldUnreadNum.should.eql 1
      done err

  it 'should hide the notification', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'notification:update'
            hits |= 0b1
            "#{data._id}".should.eql "#{app.notification1._id}"
            data.isPinned.should.eql false
            data.isHidden.should.eql true
          resolve() if hits is 0b1
        catch err
          reject err

    $hideNotification = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/notifications/#{app.notification1._id}"
        body:
          _sessionUserId: app.user2._id
          isHidden: true
      app.requestAsync options

    Promise.all [$broadcast, $hideNotification]
    .nodeify done

  it 'should create a notification', (done) ->

    text = "Hello"

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'notification:update'
            hits |= 0b1
            data.text.should.eql text
            data._userId.should.eql app.user1._id
            data.unreadNum.should.eql 0
          resolve() if hits is 0b1
        catch err
          reject err

    $createNotification = Promise.resolve().then ->
      options =
        method: 'POST'
        url: "/notifications"
        body:
          _sessionUserId: app.user1._id
          _targetId: app.user2._id
          type: 'dms'
          _teamId: app.team1._id
          text: text
      app.requestAsync options

    Promise.all [$broadcast, $createNotification]
    .nodeify done

  after cleanup
